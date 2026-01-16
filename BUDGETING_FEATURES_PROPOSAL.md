# Budgeting Features Proposal for Spendy

Based on analysis of successful budgeting apps (YNAB, Mint, PocketGuard, Goodbudget) and modern budgeting methodologies.

---

## Top 10 Budgeting Features (Prioritized)

### 1. **Category Budgets** ⭐⭐⭐
**Priority: HIGHEST** | **Complexity: Easy**

**What it is:**
Set monthly spending limits for each category (Groceries, Dining, Entertainment, etc.)

**Why it's valuable:**
- Most requested budgeting feature
- Simple to understand and use
- Immediate visual feedback on spending

**How it uses receipt data:**
- Automatically categorizes each receipt
- Tracks spending per category in real-time
- Shows "X kr spent of Y kr budget"

**UI Elements:**
- Progress bar for each category
- Color-coded: Green (under budget), Yellow (80%+), Red (over budget)
- Percentage spent displayed
- Edit budget amounts easily

**Implementation:**
```sql
CREATE TABLE category_budgets (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id),
  category TEXT NOT NULL,
  monthly_limit DECIMAL(10,2),
  start_date DATE,
  is_active BOOLEAN DEFAULT true
);
```

---

### 2. **Budget Overview Dashboard** ⭐⭐⭐
**Priority: HIGHEST** | **Complexity: Easy**

**What it is:**
Central view showing all budgets, spending, and remaining amounts at a glance

**Why it's valuable:**
- Quick financial snapshot
- Motivation to stay on track
- Easy to spot problem areas

**How it uses receipt data:**
- Aggregates all spending by category
- Calculates remaining budget
- Shows trend (up/down from last month)

**UI Elements:**
- Total budget vs. total spent
- Category breakdown with progress bars
- Days remaining in month
- Projected spending if current pace continues

**Visual Example:**
```
Total Budget: 8,000 kr
Spent: 5,234 kr (65%)
Remaining: 2,766 kr
Days left: 12

Groceries    [████████░░] 1,234/1,500 kr (82%)
Dining       [█████████░] 890/1,000 kr (89%)
Transport    [██████░░░░] 234/400 kr (59%)
```

---

### 3. **Budget Alerts & Warnings** ⭐⭐⭐
**Priority: HIGH** | **Complexity: Easy**

**What it is:**
Notifications when approaching or exceeding budget limits

**Why it's valuable:**
- Prevents overspending
- Timely intervention
- Builds budget awareness

**How it uses receipt data:**
- Triggers alert after each receipt scan
- Checks if category budget exceeded
- Calculates pace vs. time remaining

**Alert Types:**
1. **Warning (80% spent):** "You've spent 1,200 kr of your 1,500 kr grocery budget"
2. **Critical (100% spent):** "Grocery budget exceeded! 1,534/1,500 kr"
3. **Pace Alert:** "At current pace, you'll exceed dining budget by 200 kr"

**UI:**
- Toast notifications
- Badge on budget dashboard
- In-app banner

---

### 4. **Spending Insights & Trends** ⭐⭐⭐
**Priority: HIGH** | **Complexity: Medium**

**What it is:**
AI-powered insights about spending patterns and suggestions

**Why it's valuable:**
- Helps identify wasteful spending
- Actionable recommendations
- Personalized to user behavior

**How it uses receipt data:**
- Analyzes spending patterns over time
- Compares to previous months
- Identifies unusual purchases

**Insights Examples:**
- "You spent 23% more on groceries this month"
- "You shop at ICA 3x more than other stores - could save 15% at Willys"
- "Most dining spending happens on weekends (68%)"
- "You buy coffee 4x/week - that's 680 kr/month"

**Implementation:**
- Weekly digest
- Dashboard insights card
- Personalized tips

---

### 5. **Custom Budget Periods** ⭐⭐
**Priority: MEDIUM** | **Complexity: Medium**

**What it is:**
Set budgets for weekly, bi-weekly, or custom time periods (not just monthly)

**Why it's valuable:**
- Matches different pay schedules
- More flexible for gig workers
- Better for short-term goals

**How it uses receipt data:**
- Filters receipts by date range
- Calculates spending for custom period
- Rolls over unused budget (optional)

**Options:**
- Weekly budget
- Bi-weekly (paycheck-to-paycheck)
- Custom date range
- Annual budgets

---

### 6. **Envelope Budgeting** ⭐⭐
**Priority: MEDIUM** | **Complexity: Medium**

**What it is:**
Allocate money into virtual "envelopes" for different purposes

**Why it's valuable:**
- Psychological separation of funds
- Popular budgeting method
- Prevents robbing Peter to pay Paul

**How it uses receipt data:**
- Deducts from appropriate envelope
- Shows envelope balance
- Alerts when envelope empty

**UI:**
- Visual envelope cards
- Drag money between envelopes
- Lock certain envelopes

**Example:**
```
Grocery Envelope: 1,200 kr → 867 kr (after receipt)
Dining Envelope: 500 kr → 478 kr
Fun Money: 300 kr → 300 kr (unused)
```

---

### 7. **Recurring Expense Tracking** ⭐⭐
**Priority: MEDIUM** | **Complexity: Medium**

**What it is:**
Automatically detect and track recurring purchases (subscriptions, regular bills)

**Why it's valuable:**
- Identifies subscription creep
- Plans for fixed expenses
- Separates variable from fixed costs

**How it uses receipt data:**
- Detects same store + similar amount + regular interval
- Flags recurring purchases
- Predicts next occurrence

**Features:**
- List all recurring expenses
- Total monthly recurring cost
- Alerts for upcoming recurring charges
- Suggest cancellations

**Auto-Detection:**
- Netflix every month: 149 kr
- Gym membership: 299 kr
- Phone bill: 399 kr

---

### 8. **Budget Templates & Presets** ⭐⭐
**Priority: MEDIUM** | **Complexity: Easy**

**What it is:**
Pre-built budget templates based on income and common methodologies

**Why it's valuable:**
- Quick setup for new users
- Based on proven methods
- Customizable starting point

**Templates:**
1. **50/30/20 Rule**
   - 50% Needs (Groceries, Utilities)
   - 30% Wants (Dining, Entertainment)
   - 20% Savings

2. **Zero-Based Budget**
   - Assign every krona a job
   - Income - Expenses = 0

3. **Student Budget**
   - Lower entertainment/dining
   - Higher groceries (cooking at home)

4. **Family Budget**
   - Higher groceries
   - Kids activities
   - Healthcare

**Implementation:**
- Income-based calculation
- One-click apply template
- Adjust percentages

---

### 9. **Budget vs. Actual Reports** ⭐⭐
**Priority: MEDIUM** | **Complexity: Medium**

**What it is:**
Visual comparison of planned budget vs. actual spending

**Why it's valuable:**
- Shows budget accuracy
- Helps refine future budgets
- Identifies problem categories

**How it uses receipt data:**
- Aggregates monthly spending
- Compares to budget
- Generates variance report

**Visualizations:**
- Side-by-side bar charts
- Variance percentage
- Traffic light colors
- Export to CSV/PDF

**Example Report:**
```
November 2025 Budget Report

Category      Budget    Actual    Variance
-------------------------------------------
Groceries     1,500 kr  1,687 kr  +12% 🔴
Dining        800 kr    623 kr    -22% 🟢
Transport     400 kr    412 kr    +3% 🟡
Entertainment 500 kr    289 kr    -42% 🟢
```

---

### 10. **Smart Budget Recommendations** ⭐
**Priority: LOW** | **Complexity: Hard**

**What it is:**
AI suggests budget amounts based on your spending history

**Why it's valuable:**
- Data-driven budgeting
- Realistic targets
- Learns from your behavior

**How it uses receipt data:**
- Analyzes 3-6 months of spending
- Calculates average + standard deviation
- Suggests realistic budgets

**Features:**
- "Based on your spending, we recommend 1,600 kr for groceries"
- Seasonal adjustments
- Gradual reduction suggestions
- Auto-adjust budgets

**Example:**
```
Recommended Budget (based on last 3 months):

Groceries: 1,580 kr (avg: 1,487 kr, range: 1,245-1,756 kr)
Dining: 920 kr (avg: 856 kr, trending up)
Suggest reducing by 10% to save 92 kr/month
```

---

## Additional Features (Nice-to-Have)

### 11. **Rollover Budgets**
- Unused budget rolls to next month
- Builds savings buffer

### 12. **Budget Challenges**
- "No dining out for 7 days"
- Gamification with XP rewards
- Share progress with friends

### 13. **Store-Specific Budgets**
- "Max 500 kr/month at coffee shops"
- "No more than 3 visits to ICA per week"

### 14. **Budget Freeze/Pause**
- Lock category spending
- "No more dining spending this month"

### 15. **Family/Shared Budgets**
- Multiple users share budget
- Track individual spending
- Family overview

---

## Implementation Roadmap

### Phase 1: Core Budgeting (Week 1-2)
1. Category budgets table
2. Budget dashboard
3. Simple alerts (80%, 100%)
4. Basic progress bars

### Phase 2: Intelligence (Week 3-4)
5. Spending insights
6. Budget vs. actual reports
7. Trend analysis
8. Custom periods

### Phase 3: Advanced (Week 5-6)
9. Budget templates
10. Recurring expense detection
11. Envelope budgeting
12. Smart recommendations

---

## Database Schema

```sql
-- Category Budgets
CREATE TABLE category_budgets (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  category TEXT NOT NULL,
  monthly_limit DECIMAL(10, 2) NOT NULL,
  start_date DATE DEFAULT CURRENT_DATE,
  end_date DATE,
  is_active BOOLEAN DEFAULT true,
  rollover_enabled BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, category, start_date)
);

-- Budget Alerts
CREATE TABLE budget_alerts (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  budget_id UUID REFERENCES category_budgets(id) ON DELETE CASCADE,
  alert_type TEXT NOT NULL, -- 'warning', 'exceeded', 'pace'
  threshold DECIMAL(5, 2), -- e.g., 0.8 for 80%
  is_enabled BOOLEAN DEFAULT true,
  last_triggered TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Recurring Expenses
CREATE TABLE recurring_expenses (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  description TEXT NOT NULL,
  amount DECIMAL(10, 2),
  frequency TEXT NOT NULL, -- 'monthly', 'weekly', 'yearly'
  next_due_date DATE,
  category TEXT,
  store_name TEXT,
  is_auto_detected BOOLEAN DEFAULT false,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Budget Templates
CREATE TABLE budget_templates (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT,
  template_type TEXT, -- '50/30/20', 'zero_based', 'student', 'family'
  category_allocations JSONB, -- {category: percentage}
  is_system_template BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

---

## SQL Functions

```sql
-- Get current spending vs budget
CREATE OR REPLACE FUNCTION get_budget_status(p_user_id UUID, p_category TEXT DEFAULT NULL)
RETURNS TABLE (
  category TEXT,
  budget_limit DECIMAL(10,2),
  spent DECIMAL(10,2),
  remaining DECIMAL(10,2),
  percent_used DECIMAL(5,2),
  status TEXT -- 'good', 'warning', 'exceeded'
)
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT
    cb.category,
    cb.monthly_limit as budget_limit,
    COALESCE(SUM(ri.price), 0) as spent,
    cb.monthly_limit - COALESCE(SUM(ri.price), 0) as remaining,
    ROUND((COALESCE(SUM(ri.price), 0) / cb.monthly_limit * 100)::NUMERIC, 2) as percent_used,
    CASE
      WHEN COALESCE(SUM(ri.price), 0) > cb.monthly_limit THEN 'exceeded'
      WHEN COALESCE(SUM(ri.price), 0) > cb.monthly_limit * 0.8 THEN 'warning'
      ELSE 'good'
    END as status
  FROM category_budgets cb
  LEFT JOIN receipts r ON r.user_id = cb.user_id
    AND r.purchase_date >= DATE_TRUNC('month', CURRENT_DATE)
    AND r.purchase_date < DATE_TRUNC('month', CURRENT_DATE) + INTERVAL '1 month'
  LEFT JOIN LATERAL jsonb_array_elements(r.items) ri ON true
  WHERE cb.user_id = p_user_id
    AND cb.is_active = true
    AND (p_category IS NULL OR cb.category = p_category)
  GROUP BY cb.category, cb.monthly_limit;
END;
$$;
```

---

## UI Mockup Ideas

### Budget Dashboard
```
┌─────────────────────────────────────────┐
│ Budget Overview - January 2026          │
├─────────────────────────────────────────┤
│ Total Budget: 8,000 kr                  │
│ Spent: 5,234 kr (65%) ████████░░        │
│ Remaining: 2,766 kr • 12 days left      │
├─────────────────────────────────────────┤
│ Groceries           1,234 / 1,500 kr    │
│ [████████░░] 82% ⚠️                      │
│                                         │
│ Dining              890 / 1,000 kr      │
│ [█████████░] 89% 🔴                      │
│                                         │
│ Transport           234 / 400 kr        │
│ [██████░░░░] 59% ✓                      │
│                                         │
│ [+ Add Category Budget]                 │
└─────────────────────────────────────────┘
```

---

## Next Steps

1. **Choose Phase 1 features** to implement first
2. **Run database migrations** for budget tables
3. **Design UI** for budget dashboard
4. **Implement backend** functions
5. **Test with real data**
6. **Gather user feedback**
7. **Iterate and improve**

---

**Recommendation: Start with Features #1, #2, and #3 (Category Budgets, Dashboard, Alerts) as they provide immediate value with minimal complexity.**
