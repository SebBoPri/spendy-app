-- Migration: Add rich metadata fields to receipts table
-- This adds all the new fields for enhanced receipt data extraction

-- Add new columns to receipts table
ALTER TABLE receipts
  ADD COLUMN IF NOT EXISTS store_chain TEXT,
  ADD COLUMN IF NOT EXISTS store_address TEXT,
  ADD COLUMN IF NOT EXISTS store_city TEXT,
  ADD COLUMN IF NOT EXISTS store_postal_code TEXT,
  ADD COLUMN IF NOT EXISTS receipt_number TEXT,
  ADD COLUMN IF NOT EXISTS purchase_time TIME,
  ADD COLUMN IF NOT EXISTS currency TEXT DEFAULT 'SEK',
  ADD COLUMN IF NOT EXISTS subtotal DECIMAL(10, 2),
  ADD COLUMN IF NOT EXISTS total_discounts DECIMAL(10, 2),
  ADD COLUMN IF NOT EXISTS loyalty_points_earned INTEGER DEFAULT 0,
  ADD COLUMN IF NOT EXISTS loyalty_points_used INTEGER DEFAULT 0,
  ADD COLUMN IF NOT EXISTS items_count INTEGER,
  ADD COLUMN IF NOT EXISTS time_of_day TEXT,
  ADD COLUMN IF NOT EXISTS day_of_week TEXT;

-- Add helpful indexes for querying
CREATE INDEX IF NOT EXISTS idx_receipts_store_chain ON receipts(store_chain);
CREATE INDEX IF NOT EXISTS idx_receipts_store_city ON receipts(store_city);
CREATE INDEX IF NOT EXISTS idx_receipts_time_of_day ON receipts(time_of_day);
CREATE INDEX IF NOT EXISTS idx_receipts_day_of_week ON receipts(day_of_week);
CREATE INDEX IF NOT EXISTS idx_receipts_total_discounts ON receipts(total_discounts) WHERE total_discounts > 0;
CREATE INDEX IF NOT EXISTS idx_receipts_loyalty_points ON receipts(loyalty_points_earned) WHERE loyalty_points_earned > 0;

-- Create a view for easy querying of receipt metadata
CREATE OR REPLACE VIEW receipt_summary AS
SELECT
  id,
  user_id,
  store_name,
  store_chain,
  store_city,
  purchase_date,
  purchase_time,
  time_of_day,
  day_of_week,
  subtotal,
  total_discounts,
  total_amount,
  loyalty_points_earned,
  items_count,
  created_at
FROM receipts
ORDER BY purchase_date DESC, purchase_time DESC NULLS LAST;

-- Create a function to calculate total savings
CREATE OR REPLACE FUNCTION calculate_total_savings(p_user_id UUID)
RETURNS DECIMAL(10, 2)
LANGUAGE plpgsql
AS $$
DECLARE
  total_savings DECIMAL(10, 2);
BEGIN
  SELECT COALESCE(SUM(total_discounts), 0)
  INTO total_savings
  FROM receipts
  WHERE user_id = p_user_id;

  RETURN total_savings;
END;
$$;

-- Create a function to get shopping patterns by time of day
CREATE OR REPLACE FUNCTION get_shopping_by_time_of_day(p_user_id UUID)
RETURNS TABLE (
  time_of_day TEXT,
  receipt_count BIGINT,
  total_spent DECIMAL(10, 2),
  avg_basket_size DECIMAL(10, 2)
)
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT
    r.time_of_day,
    COUNT(*)::BIGINT as receipt_count,
    SUM(r.total_amount) as total_spent,
    AVG(r.total_amount) as avg_basket_size
  FROM receipts r
  WHERE r.user_id = p_user_id
    AND r.time_of_day IS NOT NULL
  GROUP BY r.time_of_day
  ORDER BY receipt_count DESC;
END;
$$;

-- Create a function to get top stores by spending
CREATE OR REPLACE FUNCTION get_top_stores(p_user_id UUID, p_limit INTEGER DEFAULT 10)
RETURNS TABLE (
  store_name TEXT,
  store_chain TEXT,
  store_city TEXT,
  visit_count BIGINT,
  total_spent DECIMAL(10, 2),
  total_savings DECIMAL(10, 2),
  avg_basket DECIMAL(10, 2)
)
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT
    r.store_name,
    r.store_chain,
    r.store_city,
    COUNT(*)::BIGINT as visit_count,
    SUM(r.total_amount) as total_spent,
    SUM(r.total_discounts) as total_savings,
    AVG(r.total_amount) as avg_basket
  FROM receipts r
  WHERE r.user_id = p_user_id
  GROUP BY r.store_name, r.store_chain, r.store_city
  ORDER BY total_spent DESC
  LIMIT p_limit;
END;
$$;

-- Add comment to track migration
COMMENT ON TABLE receipts IS 'Receipts table with rich metadata - updated with migration 002';
