-- Migration: Add budgeting features (Phase 1)
-- This adds category budgets, budget tracking, and alert system

-- Create category_budgets table
CREATE TABLE IF NOT EXISTS category_budgets (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,

  -- Budget details
  category TEXT NOT NULL,
  monthly_limit DECIMAL(10, 2) NOT NULL,

  -- Time period
  start_date DATE DEFAULT DATE_TRUNC('month', CURRENT_DATE),
  end_date DATE,

  -- Status
  is_active BOOLEAN DEFAULT true,
  rollover_enabled BOOLEAN DEFAULT false,

  -- Metadata
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

  UNIQUE(user_id, category, start_date)
);

-- Create budget_alerts table
CREATE TABLE IF NOT EXISTS budget_alerts (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  budget_id UUID REFERENCES category_budgets(id) ON DELETE CASCADE,

  -- Alert details
  alert_type TEXT NOT NULL, -- 'warning' (80%), 'exceeded' (100%), 'pace'
  threshold DECIMAL(5, 2), -- e.g., 0.8 for 80%
  message TEXT,

  -- Status
  is_enabled BOOLEAN DEFAULT true,
  last_triggered TIMESTAMP WITH TIME ZONE,

  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_category_budgets_user_id ON category_budgets(user_id);
CREATE INDEX IF NOT EXISTS idx_category_budgets_active ON category_budgets(user_id, is_active) WHERE is_active = true;
CREATE INDEX IF NOT EXISTS idx_budget_alerts_user_id ON budget_alerts(user_id);

-- Enable Row Level Security
ALTER TABLE category_budgets ENABLE ROW LEVEL SECURITY;
ALTER TABLE budget_alerts ENABLE ROW LEVEL SECURITY;

-- RLS Policies for category_budgets
CREATE POLICY "Users can view own budgets"
  ON category_budgets FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own budgets"
  ON category_budgets FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own budgets"
  ON category_budgets FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own budgets"
  ON category_budgets FOR DELETE
  USING (auth.uid() = user_id);

-- RLS Policies for budget_alerts
CREATE POLICY "Users can view own alerts"
  ON budget_alerts FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own alerts"
  ON budget_alerts FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own alerts"
  ON budget_alerts FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own alerts"
  ON budget_alerts FOR DELETE
  USING (auth.uid() = user_id);

-- Function to get current budget status for all categories
CREATE OR REPLACE FUNCTION get_budget_status(p_user_id UUID, p_category TEXT DEFAULT NULL)
RETURNS TABLE (
  budget_id UUID,
  category TEXT,
  budget_limit DECIMAL(10,2),
  spent DECIMAL(10,2),
  remaining DECIMAL(10,2),
  percent_used DECIMAL(5,2),
  status TEXT, -- 'good', 'warning', 'exceeded'
  days_left INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT
    cb.id as budget_id,
    cb.category,
    cb.monthly_limit as budget_limit,
    COALESCE(spending.total_spent, 0) as spent,
    cb.monthly_limit - COALESCE(spending.total_spent, 0) as remaining,
    ROUND((COALESCE(spending.total_spent, 0) / NULLIF(cb.monthly_limit, 0) * 100)::NUMERIC, 2) as percent_used,
    CASE
      WHEN COALESCE(spending.total_spent, 0) > cb.monthly_limit THEN 'exceeded'
      WHEN COALESCE(spending.total_spent, 0) > cb.monthly_limit * 0.8 THEN 'warning'
      ELSE 'good'
    END as status,
    (DATE_TRUNC('month', CURRENT_DATE) + INTERVAL '1 month' - INTERVAL '1 day')::DATE - CURRENT_DATE as days_left
  FROM category_budgets cb
  LEFT JOIN LATERAL (
    SELECT SUM(
      CASE
        WHEN r.items IS NOT NULL THEN
          (SELECT SUM((item->>'price')::DECIMAL)
           FROM jsonb_array_elements(r.items) AS item
           WHERE item->>'category' = cb.category)
        ELSE 0
      END
    ) as total_spent
    FROM receipts r
    WHERE r.user_id = cb.user_id
      AND r.purchase_date >= DATE_TRUNC('month', CURRENT_DATE)
      AND r.purchase_date < DATE_TRUNC('month', CURRENT_DATE) + INTERVAL '1 month'
  ) spending ON true
  WHERE cb.user_id = p_user_id
    AND cb.is_active = true
    AND (p_category IS NULL OR cb.category = p_category)
  ORDER BY cb.category;
END;
$$;

-- Function to get budget overview (total across all categories)
CREATE OR REPLACE FUNCTION get_budget_overview(p_user_id UUID)
RETURNS TABLE (
  total_budget DECIMAL(10,2),
  total_spent DECIMAL(10,2),
  total_remaining DECIMAL(10,2),
  percent_used DECIMAL(5,2),
  categories_count INTEGER,
  categories_exceeded INTEGER,
  categories_warning INTEGER,
  days_left INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT
    COALESCE(SUM(budget_limit), 0) as total_budget,
    COALESCE(SUM(spent), 0) as total_spent,
    COALESCE(SUM(remaining), 0) as total_remaining,
    ROUND((COALESCE(SUM(spent), 0) / NULLIF(SUM(budget_limit), 0) * 100)::NUMERIC, 2) as percent_used,
    COUNT(*)::INTEGER as categories_count,
    COUNT(*) FILTER (WHERE status = 'exceeded')::INTEGER as categories_exceeded,
    COUNT(*) FILTER (WHERE status = 'warning')::INTEGER as categories_warning,
    MAX(days_left) as days_left
  FROM get_budget_status(p_user_id);
END;
$$;

-- Function to check budgets and trigger alerts
CREATE OR REPLACE FUNCTION check_budget_alerts(p_user_id UUID, p_receipt_id UUID)
RETURNS TABLE (
  category TEXT,
  alert_type TEXT,
  message TEXT,
  percent_used DECIMAL(5,2)
)
LANGUAGE plpgsql
AS $$
DECLARE
  budget_rec RECORD;
  alert_message TEXT;
BEGIN
  -- Check each active budget
  FOR budget_rec IN
    SELECT * FROM get_budget_status(p_user_id)
  LOOP
    -- 100% exceeded alert
    IF budget_rec.status = 'exceeded' THEN
      alert_message := format(
        'Budget exceeded! You''ve spent %.2f kr of your %.2f kr %s budget (%.0f%%)',
        budget_rec.spent,
        budget_rec.budget_limit,
        budget_rec.category,
        budget_rec.percent_used
      );

      RETURN QUERY SELECT budget_rec.category, 'exceeded'::TEXT, alert_message, budget_rec.percent_used;

    -- 80% warning alert
    ELSIF budget_rec.status = 'warning' THEN
      alert_message := format(
        'Warning: You''ve spent %.2f kr of your %.2f kr %s budget (%.0f%%)',
        budget_rec.spent,
        budget_rec.budget_limit,
        budget_rec.category,
        budget_rec.percent_used
      );

      RETURN QUERY SELECT budget_rec.category, 'warning'::TEXT, alert_message, budget_rec.percent_used;
    END IF;
  END LOOP;

  RETURN;
END;
$$;

-- Function to initialize default budgets for new users
CREATE OR REPLACE FUNCTION create_default_budgets(p_user_id UUID)
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
  INSERT INTO category_budgets (user_id, category, monthly_limit)
  VALUES
    (p_user_id, 'Groceries', 3000),
    (p_user_id, 'Dining', 1000),
    (p_user_id, 'Transport', 800),
    (p_user_id, 'Entertainment', 500),
    (p_user_id, 'Shopping', 1000),
    (p_user_id, 'Healthcare', 500),
    (p_user_id, 'Other', 500)
  ON CONFLICT (user_id, category, start_date) DO NOTHING;
END;
$$;

-- Add comment to track migration
COMMENT ON TABLE category_budgets IS 'Category-based monthly budgets - added with migration 004';
COMMENT ON TABLE budget_alerts IS 'Budget alert history - added with migration 004';
