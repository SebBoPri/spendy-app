# spendy-app
THe following app is a budgeting app that can scan your recipets, and using AI, cateogirzies your items into a useful dashboard so you can overview your spending.

## Backlog 


**1.** DONE: Dashboard: "Top 10 Most Expensive & Frequent Items" Your app already has the data; we just need to add a new section to the Dashboard tab. Frequency Tracking: We will add a small script that counts how many times "Chicken" appears across all receipts. Cost Tracking: It will sum up every "Chicken" entry (e.g., 50kr + 70kr + 40kr) to show you that you've spent 160kr total on chicken this month. New Card: I will provide a new "Top Items" card that lists these top 10 items with a small progress bar for each.

**2.** User Log-ins (Personalized Accounts) Right now, your data is saved to your browser's "LocalStorage." If you clear your history or switch phones, the data is gone.
  Step 1: I will help you set up Supabase (a free database).
  Step 2: We will add a "Sign In" button to your index.html.
  Step 3: Your receipts will be saved to your specific User ID. When your partner logs in with their account, they will see their receipts, not yours.

**3.** Storage and memory on log-in.
  
**4.** Auto-Categorization Learning
  To make the app "learn," we need to add a "Custom Map" in your storage. How it will work: When you change "Cat Food" from Groceries to Pets, the app will save a note: {"cat food": "Pets"}. The Code Change: We will update your analyze.js file to look at this "Custom Map" before it makes its final guess. Result: The next time you scan "Cat Food," the AI will still see it, but your app will automatically swap the category to Pets before saving it.

**5.** Based on frequently bought items, get notificed of deals (e.g., if Chicken is frequently bought, i get deals for chicken from Coop, ICA etc)

