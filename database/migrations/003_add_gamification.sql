-- Migration: Add gamification features
-- This adds user progress, levels, XP, and savings goals

-- Create user_stats table to track progress and levels
CREATE TABLE IF NOT EXISTS user_stats (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,

  -- Level & XP system
  current_level INTEGER DEFAULT 1,
  total_xp INTEGER DEFAULT 0,

  -- Receipt tracking
  total_receipts_scanned INTEGER DEFAULT 0,
  receipts_this_month INTEGER DEFAULT 0,
  receipts_this_year INTEGER DEFAULT 0,

  -- Financial tracking
  total_spending DECIMAL(10, 2) DEFAULT 0,
  total_savings DECIMAL(10, 2) DEFAULT 0,
  spending_this_month DECIMAL(10, 2) DEFAULT 0,
  savings_this_month DECIMAL(10, 2) DEFAULT 0,

  -- Personal records
  biggest_receipt DECIMAL(10, 2) DEFAULT 0,
  biggest_discount DECIMAL(10, 2) DEFAULT 0,
  most_items_receipt INTEGER DEFAULT 0,

  -- Metadata
  last_receipt_date DATE,
  last_monthly_reset DATE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

  UNIQUE(user_id)
);

-- Create savings_goals table
CREATE TABLE IF NOT EXISTS savings_goals (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,

  -- Goal details
  target_amount DECIMAL(10, 2) NOT NULL,
  current_amount DECIMAL(10, 2) DEFAULT 0,
  goal_type TEXT DEFAULT 'monthly', -- monthly, yearly, custom

  -- Time period
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,

  -- Status
  is_active BOOLEAN DEFAULT true,
  is_completed BOOLEAN DEFAULT false,
  completed_at TIMESTAMP WITH TIME ZONE,

  -- Metadata
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_user_stats_user_id ON user_stats(user_id);
CREATE INDEX IF NOT EXISTS idx_savings_goals_user_id ON savings_goals(user_id);
CREATE INDEX IF NOT EXISTS idx_savings_goals_active ON savings_goals(user_id, is_active) WHERE is_active = true;

-- Enable Row Level Security
ALTER TABLE user_stats ENABLE ROW LEVEL SECURITY;
ALTER TABLE savings_goals ENABLE ROW LEVEL SECURITY;

-- RLS Policies for user_stats
CREATE POLICY "Users can view own stats"
  ON user_stats FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own stats"
  ON user_stats FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own stats"
  ON user_stats FOR UPDATE
  USING (auth.uid() = user_id);

-- RLS Policies for savings_goals
CREATE POLICY "Users can view own goals"
  ON savings_goals FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own goals"
  ON savings_goals FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own goals"
  ON savings_goals FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own goals"
  ON savings_goals FOR DELETE
  USING (auth.uid() = user_id);

-- Function to calculate level from XP
-- Level formula: Level = floor(sqrt(XP / 100)) + 1
-- XP needed for level N: (N-1)^2 * 100
CREATE OR REPLACE FUNCTION calculate_level(xp INTEGER)
RETURNS INTEGER
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN FLOOR(SQRT(xp::FLOAT / 100)) + 1;
END;
$$;

-- Function to calculate XP needed for next level
CREATE OR REPLACE FUNCTION xp_for_next_level(current_level INTEGER)
RETURNS INTEGER
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN current_level * current_level * 100;
END;
$$;

-- Function to get level name
CREATE OR REPLACE FUNCTION get_level_name(level INTEGER)
RETURNS TEXT
LANGUAGE plpgsql
AS $$
BEGIN
  CASE
    WHEN level >= 20 THEN RETURN 'Platinum';
    WHEN level >= 15 THEN RETURN 'Diamond';
    WHEN level >= 10 THEN RETURN 'Gold';
    WHEN level >= 5 THEN RETURN 'Silver';
    ELSE RETURN 'Bronze';
  END CASE;
END;
$$;

-- Function to award XP and update stats when receipt is saved
CREATE OR REPLACE FUNCTION award_receipt_xp()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
  xp_earned INTEGER := 10; -- Base XP per receipt
  bonus_xp INTEGER := 0;
  new_level INTEGER;
BEGIN
  -- Calculate bonus XP
  IF NEW.total_discounts > 0 THEN
    bonus_xp := bonus_xp + 5; -- Bonus for finding discounts
  END IF;

  IF NEW.items_count > 10 THEN
    bonus_xp := bonus_xp + 5; -- Bonus for large receipts
  END IF;

  -- Insert or update user_stats
  INSERT INTO user_stats (
    user_id,
    total_xp,
    total_receipts_scanned,
    receipts_this_month,
    receipts_this_year,
    total_spending,
    total_savings,
    spending_this_month,
    savings_this_month,
    biggest_receipt,
    biggest_discount,
    most_items_receipt,
    last_receipt_date,
    last_monthly_reset
  )
  VALUES (
    NEW.user_id,
    xp_earned + bonus_xp,
    1,
    1,
    1,
    COALESCE(NEW.total_amount, 0),
    COALESCE(NEW.total_discounts, 0),
    COALESCE(NEW.total_amount, 0),
    COALESCE(NEW.total_discounts, 0),
    COALESCE(NEW.total_amount, 0),
    COALESCE(NEW.total_discounts, 0),
    COALESCE(NEW.items_count, 0),
    NEW.purchase_date,
    DATE_TRUNC('month', CURRENT_DATE)
  )
  ON CONFLICT (user_id) DO UPDATE SET
    total_xp = user_stats.total_xp + xp_earned + bonus_xp,
    total_receipts_scanned = user_stats.total_receipts_scanned + 1,
    receipts_this_month = CASE
      WHEN user_stats.last_monthly_reset < DATE_TRUNC('month', CURRENT_DATE) THEN 1
      ELSE user_stats.receipts_this_month + 1
    END,
    receipts_this_year = user_stats.receipts_this_year + 1,
    total_spending = user_stats.total_spending + COALESCE(NEW.total_amount, 0),
    total_savings = user_stats.total_savings + COALESCE(NEW.total_discounts, 0),
    spending_this_month = CASE
      WHEN user_stats.last_monthly_reset < DATE_TRUNC('month', CURRENT_DATE) THEN COALESCE(NEW.total_amount, 0)
      ELSE user_stats.spending_this_month + COALESCE(NEW.total_amount, 0)
    END,
    savings_this_month = CASE
      WHEN user_stats.last_monthly_reset < DATE_TRUNC('month', CURRENT_DATE) THEN COALESCE(NEW.total_discounts, 0)
      ELSE user_stats.savings_this_month + COALESCE(NEW.total_discounts, 0)
    END,
    biggest_receipt = GREATEST(user_stats.biggest_receipt, COALESCE(NEW.total_amount, 0)),
    biggest_discount = GREATEST(user_stats.biggest_discount, COALESCE(NEW.total_discounts, 0)),
    most_items_receipt = GREATEST(user_stats.most_items_receipt, COALESCE(NEW.items_count, 0)),
    last_receipt_date = NEW.purchase_date,
    last_monthly_reset = CASE
      WHEN user_stats.last_monthly_reset < DATE_TRUNC('month', CURRENT_DATE) THEN DATE_TRUNC('month', CURRENT_DATE)
      ELSE user_stats.last_monthly_reset
    END,
    updated_at = NOW();

  -- Update current_level based on total_xp
  UPDATE user_stats
  SET current_level = calculate_level(total_xp)
  WHERE user_id = NEW.user_id;

  -- Update active savings goals
  UPDATE savings_goals
  SET
    current_amount = current_amount + COALESCE(NEW.total_discounts, 0),
    is_completed = CASE
      WHEN current_amount + COALESCE(NEW.total_discounts, 0) >= target_amount THEN true
      ELSE false
    END,
    completed_at = CASE
      WHEN current_amount + COALESCE(NEW.total_discounts, 0) >= target_amount AND completed_at IS NULL THEN NOW()
      ELSE completed_at
    END,
    updated_at = NOW()
  WHERE user_id = NEW.user_id
    AND is_active = true
    AND NEW.purchase_date BETWEEN start_date AND end_date;

  RETURN NEW;
END;
$$;

-- Create trigger to award XP when receipt is inserted
DROP TRIGGER IF EXISTS trigger_award_receipt_xp ON receipts;
CREATE TRIGGER trigger_award_receipt_xp
  AFTER INSERT ON receipts
  FOR EACH ROW
  EXECUTE FUNCTION award_receipt_xp();

-- Function to get user progress summary
CREATE OR REPLACE FUNCTION get_user_progress(p_user_id UUID)
RETURNS TABLE (
  current_level INTEGER,
  level_name TEXT,
  total_xp INTEGER,
  xp_for_next_level INTEGER,
  xp_progress_percent NUMERIC,
  total_receipts INTEGER,
  receipts_this_month INTEGER,
  total_savings NUMERIC,
  savings_this_month NUMERIC,
  biggest_receipt NUMERIC,
  biggest_discount NUMERIC,
  most_items_receipt INTEGER
)
LANGUAGE plpgsql
AS $$
DECLARE
  stats RECORD;
  current_level_xp INTEGER;
  next_level_xp INTEGER;
BEGIN
  -- Get user stats
  SELECT * INTO stats FROM user_stats WHERE user_id = p_user_id;

  IF NOT FOUND THEN
    -- Return default values if no stats exist
    RETURN QUERY SELECT
      1::INTEGER,
      'Bronze'::TEXT,
      0::INTEGER,
      100::INTEGER,
      0::NUMERIC,
      0::INTEGER,
      0::INTEGER,
      0::NUMERIC,
      0::NUMERIC,
      0::NUMERIC,
      0::NUMERIC,
      0::INTEGER;
    RETURN;
  END IF;

  -- Calculate XP progress
  current_level_xp := (stats.current_level - 1) * (stats.current_level - 1) * 100;
  next_level_xp := stats.current_level * stats.current_level * 100;

  RETURN QUERY SELECT
    stats.current_level,
    get_level_name(stats.current_level),
    stats.total_xp,
    next_level_xp - stats.total_xp,
    ROUND((stats.total_xp - current_level_xp)::NUMERIC / (next_level_xp - current_level_xp) * 100, 1),
    stats.total_receipts_scanned,
    stats.receipts_this_month,
    stats.total_savings,
    stats.savings_this_month,
    stats.biggest_receipt,
    stats.biggest_discount,
    stats.most_items_receipt;
END;
$$;

-- Function to get active savings goal
CREATE OR REPLACE FUNCTION get_active_savings_goal(p_user_id UUID)
RETURNS TABLE (
  goal_id UUID,
  target_amount NUMERIC,
  current_amount NUMERIC,
  progress_percent NUMERIC,
  days_remaining INTEGER,
  is_completed BOOLEAN
)
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT
    id,
    savings_goals.target_amount,
    savings_goals.current_amount,
    ROUND((savings_goals.current_amount / savings_goals.target_amount * 100)::NUMERIC, 1),
    (end_date - CURRENT_DATE)::INTEGER,
    savings_goals.is_completed
  FROM savings_goals
  WHERE user_id = p_user_id
    AND is_active = true
    AND CURRENT_DATE BETWEEN start_date AND end_date
  ORDER BY created_at DESC
  LIMIT 1;
END;
$$;

-- Add comment to track migration
COMMENT ON TABLE user_stats IS 'User statistics and progress tracking - added with migration 003';
COMMENT ON TABLE savings_goals IS 'User savings goals - added with migration 003';
