# Database Migrations

This folder contains SQL migrations for the Spendy app database.

## How to Run Migrations

### Option 1: Supabase Dashboard (Recommended)

1. Go to your Supabase project dashboard
2. Click **"SQL Editor"** in the left sidebar
3. Click **"New query"**
4. Copy the contents of the migration file you want to run
5. Paste into the SQL editor
6. Click **"Run"** (or press Ctrl+Enter)

### Option 2: Supabase CLI

```bash
# Make sure you're in the project directory
cd spendy-app

# Run a specific migration
supabase db execute --file database/migrations/002_add_rich_metadata.sql
```

## Migrations

### 002_add_rich_metadata.sql

**Purpose**: Adds rich metadata fields to support enhanced receipt data extraction

**What it does**:
- Adds store chain, address, city, postal code columns
- Adds receipt number, purchase time, currency columns
- Adds financial columns: subtotal, total_discounts
- Adds loyalty points columns
- Adds analytics columns: items_count, time_of_day, day_of_week
- Creates helpful indexes for performance
- Creates useful views and functions for querying data

**New columns**:
- `store_chain` - Parent company (e.g., "ICA", "Willys")
- `store_address` - Full street address
- `store_city` - City name
- `store_postal_code` - Postal/ZIP code
- `receipt_number` - Receipt/transaction number
- `purchase_time` - Time of purchase (HH:MM:SS)
- `currency` - Currency code (default: SEK)
- `subtotal` - Subtotal before discounts
- `total_discounts` - Total discount amount
- `loyalty_points_earned` - Points earned on this purchase
- `loyalty_points_used` - Points redeemed
- `items_count` - Number of items on receipt
- `time_of_day` - morning/afternoon/evening/night
- `day_of_week` - Monday, Tuesday, etc.

**New functions**:
- `calculate_total_savings(user_id)` - Get total savings from discounts
- `get_shopping_by_time_of_day(user_id)` - Analyze shopping patterns
- `get_top_stores(user_id, limit)` - Get most-shopped stores

## Usage Examples

After running the migration, you can use the new functions:

```sql
-- Get your total savings
SELECT calculate_total_savings('your-user-id-here');

-- Analyze when you shop most
SELECT * FROM get_shopping_by_time_of_day('your-user-id-here');

-- See your top 5 stores
SELECT * FROM get_top_stores('your-user-id-here', 5);

-- Query receipts with rich metadata
SELECT
  store_name,
  store_chain,
  store_city,
  purchase_date,
  time_of_day,
  total_amount,
  total_discounts,
  loyalty_points_earned
FROM receipts
WHERE user_id = 'your-user-id-here'
ORDER BY purchase_date DESC;
```

## Verification

After running the migration, verify it worked:

```sql
-- Check that new columns exist
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'receipts'
  AND column_name IN (
    'store_chain',
    'store_city',
    'total_discounts',
    'time_of_day'
  );

-- Should return 4 rows if successful
```
