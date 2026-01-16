# Quick Fix Guide - Database Migration

## Error: "Could not find the table 'public.savings_goals' in the schema cache"

This error means the gamification database migration hasn't been run yet.

### How to Fix (Takes 2 minutes)

1. **Go to Supabase Dashboard**
   - Visit: https://supabase.com/dashboard
   - Select your Spendy project

2. **Open SQL Editor**
   - Click **"SQL Editor"** in the left sidebar
   - Click **"New query"** button

3. **Run the Migration**
   - Open the file: `database/migrations/003_add_gamification.sql`
   - Copy the **entire contents** of the file
   - Paste into the SQL Editor
   - Click **"Run"** (or press Ctrl+Enter)

4. **Expected Result**
   - You should see: **"Success. No rows returned"**
   - This is normal and correct!

5. **Verify It Worked**
   - Run this query:
   ```sql
   SELECT table_name
   FROM information_schema.tables
   WHERE table_schema = 'public'
   AND table_name IN ('user_stats', 'savings_goals');
   ```
   - You should see 2 tables listed

6. **Test the App**
   - Refresh your Spendy app
   - Go to Dashboard
   - Try setting a savings goal
   - It should work now!

### What This Migration Does

Creates these tables:
- `user_stats` - Tracks your level, XP, and statistics
- `savings_goals` - Stores your monthly savings goals

Adds these functions:
- `get_user_progress()` - Get your current level and stats
- `get_active_savings_goal()` - Get your active goal
- `calculate_total_savings()` - Calculate total savings

Adds automatic features:
- XP awarded automatically when you save a receipt
- Goals updated automatically as you find discounts
- Level calculated automatically from XP

### Still Having Issues?

1. **Check you're in the right project** in Supabase
2. **Verify you have permission** to run SQL queries
3. **Look for error messages** in the SQL Editor
4. **Check browser console** (F12) for JavaScript errors

Once you run this migration, all gamification features will work perfectly!
