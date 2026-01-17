# Budgeting Features Guide - Phase 1 Complete!

Your Spendy app now includes **comprehensive budgeting features** to help you control spending and reach financial goals!

---

## What's Been Implemented (Phase 1)

### 1. Category Budgets
Set monthly spending limits for any category (Groceries, Dining, Transport, etc.)

**Features:**
- Create budgets for multiple categories
- Set custom monthly limits
- Real-time tracking as you scan receipts
- Visual progress bars with color-coded status
- Edit or update budgets anytime

**How it works:**
- Each receipt automatically updates spending in relevant categories
- Budget calculations happen in real-time
- Monthly budgets reset automatically

### 2. Budget Overview Dashboard
Central command center showing all your budgets at a glance

**What you see:**
- **Total Budget Summary**
  - Total monthly budget across all categories
  - Total spent this month
  - Remaining budget
  - Days left in the month
  - Overall progress bar

- **Individual Category Cards**
  - Spent vs. Budget limit
  - Visual progress bar
  - Percentage used
  - Status indicator (✓ good, ⚠️ warning, 🔴 exceeded)
  - Remaining amount
  - Quick edit button

**Visual Design:**
- Beautiful gradient header card
- Color-coded progress bars:
  - Green: Under 80% (on track)
  - Yellow: 80-100% (warning)
  - Red: Over 100% (exceeded)

### 3. Budget Alerts & Warnings
Automatic notifications when approaching or exceeding budgets

**Alert Types:**

1. **Warning Alert (80% spent)**
   - Triggers when you've used 80% of category budget
   - Yellow warning toast notification
   - Example: "⚠️ Warning: You've spent 1,200 kr of your 1,500 kr Groceries budget (80%)"

2. **Exceeded Alert (100% spent)**
   - Triggers when budget is exceeded
   - Red error toast notification
   - Example: "🚨 Budget exceeded! You've spent 1,534 kr of your 1,500 kr Groceries budget (102%)"

**When alerts appear:**
- Immediately after saving a receipt
- Only for categories that cross thresholds
- Alerts appear as toast notifications
- Budget dashboard auto-updates

---

## How to Use

### Step 1: Run Database Migration

**IMPORTANT:** You must run the migration before budgeting features will work.

1. Go to **Supabase Dashboard** → Your Project
2. Click **SQL Editor** in the sidebar
3. Click **New query**
4. Open the file: `database/migrations/004_add_budgeting.sql`
5. Copy the **entire contents**
6. Paste into SQL Editor
7. Click **Run** (or press Ctrl+Enter)

**Expected result:** "Success. No rows returned"

### Step 2: Verify Migration

Run this query to verify tables were created:

```sql
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_name IN ('category_budgets', 'budget_alerts');
```

**Expected result:** 2 rows showing both tables

### Step 3: Create Your First Budget

1. Go to your app Dashboard tab
2. You'll see **"Budget Your Spending"** card
3. Click **"Create Your First Budget"**
4. In the modal:
   - Select a category (e.g., "Groceries")
   - Enter monthly limit (e.g., "3000")
   - Click **"Set Budget"**
5. Budget is created instantly!

### Step 4: Add More Budgets

- Click **"+ Add Budget"** button
- Repeat for other categories
- Suggested categories:
  - Groceries: 3000 kr
  - Dining: 1000 kr
  - Transport: 800 kr
  - Entertainment: 500 kr
  - Shopping: 1000 kr

### Step 5: Track Your Spending

1. Scan receipts as usual
2. Watch budget progress update automatically
3. Get alerts when approaching limits
4. Adjust budgets as needed

---

## Features in Detail

### Budget Overview Card

**Total Budget Summary (Purple gradient header):**
```
Total Budget: 8,000 kr          Spent: 5,234 kr
[████████░░] 65%
2,766 kr remaining • 12 days left
```

### Individual Category Cards

**Example - Groceries (Warning state):**
```
Groceries                               ⚠️
1,234 kr of 1,500 kr                    82%
[████████░░]
266 kr remaining                        Edit
```

**Example - Dining (Exceeded state):**
```
Dining                                  🔴
1,089 kr of 1,000 kr                    109%
[██████████]
-89 kr remaining                        Edit
```

**Example - Transport (On track):**
```
Transport                               ✓
234 kr of 800 kr                        29%
[███░░░░░░░]
566 kr remaining                        Edit
```

### Budget Modal

Create or edit budgets easily:

```
Set Category Budget

Category
[Select dropdown ▼]
  - Groceries
  - Dining
  - Transport
  - Entertainment
  - Shopping
  - Healthcare
  - Household
  - Personal Care
  - Other

Monthly Limit (kr)
[1500]
Maximum amount to spend in this category each month

[Set Budget]  [Cancel]
```

---

## Database Schema

### category_budgets Table

Stores your budget limits:

```sql
- id: Unique budget ID
- user_id: Your user ID
- category: Budget category name
- monthly_limit: Maximum spending allowed
- start_date: When budget period starts
- is_active: Whether budget is currently active
- created_at / updated_at: Timestamps
```

### budget_alerts Table

Tracks alert history:

```sql
- id: Unique alert ID
- user_id: Your user ID
- budget_id: Related budget
- alert_type: 'warning' or 'exceeded'
- threshold: Percentage threshold (0.8 or 1.0)
- last_triggered: When alert was sent
```

---

## SQL Functions

Three powerful functions for budget calculations:

### 1. get_budget_status(user_id, category)

Returns current status of all budgets:

```sql
SELECT * FROM get_budget_status('your-user-id');
```

**Returns:**
- budget_id
- category
- budget_limit
- spent (current month)
- remaining
- percent_used
- status ('good', 'warning', 'exceeded')
- days_left (in month)

**Example:**
```
category      budget_limit  spent     remaining  percent_used  status
Groceries     1500          1234      266        82.27         warning
Dining        1000          890       110        89.00         warning
Transport     800           234       566        29.25         good
```

### 2. get_budget_overview(user_id)

Returns summary across all budgets:

```sql
SELECT * FROM get_budget_overview('your-user-id');
```

**Returns:**
- total_budget (sum of all limits)
- total_spent (sum of all spending)
- total_remaining
- percent_used
- categories_count
- categories_exceeded (count)
- categories_warning (count)
- days_left

### 3. check_budget_alerts(user_id, receipt_id)

Checks if new receipt triggers any alerts:

```sql
SELECT * FROM check_budget_alerts('your-user-id', 'receipt-id');
```

**Returns:**
- category
- alert_type
- message
- percent_used

**Automatically called** after each receipt is saved.

---

## How Budget Tracking Works

### Automatic Calculation

When you save a receipt:

1. **Items are categorized**
   - Each item has a category from AI analysis
   - Item prices are summed by category

2. **Budgets are checked**
   - All active budgets for current month are loaded
   - Spending is calculated from all receipts this month
   - Progress is calculated: `(spent / limit) * 100`

3. **Alerts are triggered**
   - If any budget crosses 80% → Warning alert
   - If any budget crosses 100% → Exceeded alert
   - Multiple alerts can trigger from one receipt

4. **UI updates**
   - Dashboard refreshes with new spending totals
   - Progress bars animate to new percentages
   - Colors update based on status

### Monthly Reset

Budgets automatically reset:

- Spending calculations only include receipts from current calendar month
- New budgets start on the 1st of the month
- Old budget data is preserved in database
- You can view historical budget performance

---

## Example User Journey

### Day 1: Setup

1. Create budgets:
   - Groceries: 3,000 kr
   - Dining: 800 kr
   - Transport: 500 kr
   - Total: 4,300 kr

2. Dashboard shows:
   ```
   Total Budget: 4,300 kr
   Spent: 0 kr
   Remaining: 4,300 kr
   30 days left
   ```

### Day 10: First Warning

1. Scan grocery receipt: 567 kr
2. Scan restaurant receipt: 234 kr
3. Scan grocery receipt: 1,678 kr
4. **Alert appears:** "⚠️ Warning: You've spent 2,245 kr of your 3,000 kr Groceries budget (75%)"

### Day 25: Budget Exceeded

1. Scan grocery receipt: 892 kr
2. **Alert appears:** "🚨 Budget exceeded! You've spent 3,137 kr of your 3,000 kr Groceries budget (105%)"
3. Dashboard shows Groceries card in red

### End of Month

Budget status:
```
Groceries:    3,137 kr / 3,000 kr (105%) 🔴 Exceeded
Dining:         723 kr /   800 kr (90%)  ⚠️ Warning
Transport:      234 kr /   500 kr (47%)  ✓  Good

Total:        4,094 kr / 4,300 kr (95%)
Saved:          206 kr this month
```

---

## Tips for Success

### 1. Start Conservative
- Set realistic budgets based on past spending
- It's easier to increase than decrease
- Review after first month

### 2. Use All Categories
- Don't lump everything into "Other"
- Specific categories give better insights
- Categories match receipt AI analysis

### 3. Monitor Weekly
- Check dashboard weekly
- Adjust spending if approaching limits
- Edit budgets mid-month if needed

### 4. Pay Attention to Alerts
- Warnings at 80% give time to adjust
- Don't ignore exceeded alerts
- Use alerts to change behavior

### 5. Adjust Seasonally
- December groceries may be higher
- Summer may have more dining
- Update budgets as life changes

---

## Troubleshooting

### "Budget not showing on dashboard"
- Ensure you ran the database migration
- Check that category_budgets table exists
- Refresh the dashboard tab

### "Spending not updating"
- Verify receipt items have categories
- Check browser console for errors
- Ensure Supabase connection is working

### "No alerts appearing"
- Check that budget threshold is crossed
- Verify check_budget_alerts function exists
- Look for errors in browser console

### "Can't create budget"
- Ensure you're logged in to Supabase
- Check category name is valid
- Verify monthly limit is positive number

---

## What's Next (Future Phases)

With Phase 1 complete, you can look forward to:

### Phase 2: Intelligence (Coming Soon)
- **Spending Insights** - "You spend 23% more on groceries than average"
- **Budget vs. Actual Reports** - Monthly comparison charts
- **Trend Analysis** - Identify patterns in spending
- **Custom Periods** - Weekly, bi-weekly budgets

### Phase 3: Advanced Features
- **Budget Templates** - 50/30/20 rule, Zero-based budgeting
- **Recurring Expense Detection** - Auto-identify subscriptions
- **Envelope Budgeting** - Virtual envelopes for categories
- **Smart Recommendations** - AI suggests optimal budgets

---

## Database Queries for Analysis

### See all your budgets
```sql
SELECT * FROM category_budgets
WHERE user_id = 'your-user-id'
  AND is_active = true
ORDER BY category;
```

### Check which budgets are exceeded
```sql
SELECT category, monthly_limit, spent, percent_used
FROM get_budget_status('your-user-id')
WHERE status = 'exceeded';
```

### See alert history
```sql
SELECT ba.alert_type, ba.message, ba.last_triggered, cb.category
FROM budget_alerts ba
JOIN category_budgets cb ON ba.budget_id = cb.id
WHERE ba.user_id = 'your-user-id'
ORDER BY ba.last_triggered DESC
LIMIT 10;
```

### Calculate total spending by category this month
```sql
SELECT
  item->>'category' as category,
  SUM((item->>'price')::DECIMAL) as total_spent,
  COUNT(*) as items_count
FROM receipts,
LATERAL jsonb_array_elements(items) as item
WHERE user_id = 'your-user-id'
  AND purchase_date >= DATE_TRUNC('month', CURRENT_DATE)
  AND purchase_date < DATE_TRUNC('month', CURRENT_DATE) + INTERVAL '1 month'
GROUP BY item->>'category'
ORDER BY total_spent DESC;
```

---

## Summary

You now have a complete budgeting system that:

✅ Tracks spending by category in real-time
✅ Shows visual progress with color-coded indicators
✅ Alerts you when approaching or exceeding limits
✅ Automatically calculates all budget math
✅ Updates instantly when you scan receipts
✅ Works seamlessly with existing receipt data
✅ Resets monthly without manual intervention

**Start budgeting today!** Create your first budget and watch your spending come under control.

---

**Questions?** Check the browser console (F12) for error messages or verify your migration ran successfully.

**Ready to take control of your spending? Set your first budget now!** 🎯
