# Gamification Features Guide

Your Spendy app now includes **4 powerful gamification features** to make receipt scanning fun and rewarding!

---

## What's Been Added

### 1. Progress Bars & Levels (XP System)
- **Earn XP** for every receipt you scan
- **Level up** from Bronze → Silver → Gold → Diamond → Platinum
- **Visual progress bar** showing your journey to the next level
- **Celebration animations** when you level up

**XP Rewards:**
- 10 XP per receipt (base)
- +5 XP bonus if receipt has discounts
- +5 XP bonus if receipt has 10+ items

**Level Requirements:**
- Level 1 (Bronze): 0 XP
- Level 5 (Silver): 1,600 XP (160 receipts)
- Level 10 (Gold): 8,100 XP (810 receipts)
- Level 15 (Diamond): 19,600 XP
- Level 20 (Platinum): 36,100 XP

### 2. Savings Goals
- **Set monthly targets** for discount savings
- **Track progress** with a beautiful progress bar
- **Get notified** when you hit your goal
- **Celebrate** with confetti when goal is reached

### 3. Statistics Dashboard
Shows your personal bests:
- **Receipts This Month** - Your scanning streak
- **Total Savings** - All discounts captured
- **Biggest Receipt** - Your largest shopping trip
- **Best Discount** - Most saved on single receipt

### 4. Quick Stats After Upload
After scanning each receipt, you'll see:
- "Receipt #15 this month!"
- "You saved 47.50 kr on this receipt"
- Confetti animation
- Level up notifications (if you leveled up)
- Goal completion alerts (if goal reached)

---

## How to Activate

### Step 1: Run Database Migration

1. Go to **Supabase Dashboard** → Your Project
2. Click **SQL Editor** in the sidebar
3. Click **New query**
4. Open `database/migrations/003_add_gamification.sql`
5. Copy the entire contents
6. Paste into SQL Editor
7. Click **Run** (or Ctrl+Enter)

**Expected result**: "Success. No rows returned"

### Step 2: Verify Migration

Run this query to verify:

```sql
-- Check that new tables exist
SELECT table_name
FROM information_schema.tables
WHERE table_name IN ('user_stats', 'savings_goals');

-- Should return 2 rows
```

### Step 3: Test It Out!

1. Go to your app: https://spendy-app-sebastian-bs-projects-93a4e006.vercel.app/
2. **Scan a receipt** (or upload one you already have)
3. Watch the confetti fall!
4. Click **Dashboard** tab
5. See your:
   - Level & XP progress
   - Quick stats
   - Option to set a savings goal

---

## Features in Detail

### Level Card (Dashboard)
- Shows current level and rank name
- Displays total XP earned
- Progress bar to next level
- XP remaining to level up

### Savings Goal Card (Dashboard)
- Set a monthly target (e.g., save 500 kr in discounts)
- See progress: "247 kr of 500 kr"
- Days remaining in month
- Progress percentage
- Edit/update goal anytime

### Quick Stats Card (Dashboard)
Four key metrics at a glance:
- Receipts scanned this month
- Total savings from all receipts
- Biggest single receipt amount
- Best discount on single receipt

### Celebration Modals
1. **Level Up Modal** - Shows when you reach a new level
2. **Goal Complete Modal** - Shows when you hit your savings target
3. **Confetti Animation** - Colorful confetti falls on achievements

---

## Database Schema

### user_stats Table
Tracks your progress:
- `current_level` - Your current level (1-20+)
- `total_xp` - Total XP earned
- `total_receipts_scanned` - All-time receipt count
- `receipts_this_month` - Current month's receipts
- `total_savings` - All-time savings from discounts
- `savings_this_month` - Current month's savings
- `biggest_receipt` - Largest receipt amount
- `biggest_discount` - Best discount received
- `most_items_receipt` - Most items on single receipt

### savings_goals Table
Your monthly goals:
- `target_amount` - Goal amount (kr)
- `current_amount` - Progress so far (kr)
- `start_date` / `end_date` - Goal period
- `is_active` - Currently tracking
- `is_completed` - Goal reached

---

## How It Works

### Automatic XP Awarding
When you save a receipt, a database trigger:
1. Awards 10 XP (+ bonuses for discounts/large receipts)
2. Updates your stats (receipts count, savings, etc.)
3. Calculates your new level
4. Updates active savings goals
5. Checks for personal records

### Level Calculation
Formula: `Level = floor(sqrt(XP / 100)) + 1`

This means:
- Levels get progressively harder
- Early levels are quick (encourages engagement)
- Later levels take dedication (rewards long-term users)

### Monthly Reset
The system automatically:
- Tracks "this month" separately
- Resets monthly counters on first scan of new month
- Keeps all-time totals intact
- Carries over inactive goals to history

---

## Tips for Engagement

1. **Set Realistic Goals** - Start with 200-300 kr/month, adjust as you learn your patterns
2. **Check Dashboard Regularly** - See your progress and stay motivated
3. **Aim for Combos** - Receipts with discounts give bonus XP!
4. **Track Personal Bests** - Try to beat your biggest receipt/discount records
5. **Level Up Strategically** - Plan shopping trips to maximize XP

---

## Troubleshooting

### "Goal not showing"
- Make sure you clicked "Set Goal" and entered a target amount
- Check that migration was run successfully
- Refresh the dashboard

### "Stats not updating"
- Make sure you're logged in to Supabase
- Check that receipts are being saved to cloud (not just locally)
- Verify migration created the user_stats table

### "Level not changing"
- Levels require progressively more XP
- Check your XP progress - you may need more receipts to level up
- Verify the trigger is working: check user_stats table

---

## Example User Journey

**Week 1:**
- Scan 3 receipts → Earn 30 XP → Level 1 (Bronze)
- Set goal: Save 300 kr this month
- Current savings: 45 kr (15%)

**Week 2:**
- Scan 7 more receipts (2 with big discounts) → Earn 80 XP → Total 110 XP → Level 2!
- Savings: 138 kr (46%)
- Biggest receipt: 287 kr

**Week 3:**
- Scan 5 receipts → Earn 50 XP → Total 160 XP
- Savings: 243 kr (81%)
- Almost at goal!

**Week 4:**
- Scan 4 receipts → Earn 40 XP → Total 200 XP → Level 2 (near Level 3)
- Savings: 327 kr → **Goal Complete!** 🎉
- Confetti falls, celebration modal appears

**End of Month Stats:**
- Level 2, 200 XP (need 100 more for Level 3)
- 19 receipts scanned
- 327 kr saved
- Beat your savings goal by 27 kr!

---

## What's Next?

With this foundation, you can easily add:
1. **Achievements/Badges** - Unlock special badges
2. **Streaks** - Consecutive day scanning bonuses
3. **Challenges** - Weekly challenges for extra XP
4. **Leaderboards** - Compete with friends (opt-in)
5. **Store-specific goals** - "Save 100 kr at ICA this month"

---

**You're all set! Start scanning receipts and watch your level grow!** 🚀

Questions? Check the console for errors or verify your migration ran successfully.
