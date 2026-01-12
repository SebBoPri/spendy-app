# 🚀 Fixed Deployment Guide

## Issues Fixed in This Version:
✅ API 404 error (added vercel.json configuration)
✅ Storage error (added localStorage fallback)
✅ CORS headers configured properly

---

## 📦 What's Included

```
vercel-deployment-v2/
├── index.html          (App with localStorage fallback)
├── vercel.json         (Vercel configuration - IMPORTANT!)
└── api/
    └── analyze.js      (Secure backend)
```

---

## 🚀 Quick Deployment Steps

### **Step 1: Get Your Claude API Key**

1. Go to https://console.anthropic.com/
2. Sign up/Login
3. Navigate to "API Keys"
4. Create new key or copy existing
5. **Save it** - you'll need it in Step 3

---

### **Step 2: Deploy to Vercel**

**Option A: Vercel CLI (Easiest)**

```bash
# Navigate to the folder
cd vercel-deployment-v2

# Deploy
vercel

# Follow prompts:
# - Set up and deploy? → Yes (Enter)
# - Which scope? → Your account (Enter)
# - Link to existing project? → No (type 'n')
# - Project name? → spendy-app
# - Directory? → . (Enter)
```

You'll get a URL like: `https://spendy-app-xxx.vercel.app`

**Option B: GitHub**

1. Create GitHub repo: `spendy-app`
2. Upload ALL files (keep folder structure intact!)
   ```
   repo/
   ├── index.html
   ├── vercel.json
   └── api/
       └── analyze.js
   ```
3. Go to Vercel → Import from GitHub
4. Select repository → Deploy

---

### **Step 3: Add API Key (CRITICAL!)**

🚨 **This is what makes receipt scanning work!**

1. Go to https://vercel.com/dashboard
2. Click your project
3. Go to **Settings** → **Environment Variables**
4. Click **Add New**:
   - **Name:** `ANTHROPIC_API_KEY`
   - **Value:** (your API key from Step 1)
   - **Environments:** Check ALL boxes
5. Click **Save**

---

### **Step 4: Redeploy**

After adding the API key, you MUST redeploy:

1. Go to **Deployments** tab
2. Click **•••** (three dots) on the latest deployment
3. Click **Redeploy**
4. Wait ~30 seconds

---

### **Step 5: Test!**

1. Open your URL
2. Go to "Scan Receipt"
3. Upload a receipt photo
4. **Should work!** 🎉

---

## 🐛 Still Getting Errors?

### **Error: "API key not configured"**
✅ **Fix:**
- Double-check the environment variable name is EXACTLY: `ANTHROPIC_API_KEY`
- Make sure you clicked "Save"
- Make sure you redeployed after adding it
- Try adding the variable again

### **Error: "404 on /api/analyze"**
✅ **Fix:**
- Make sure `vercel.json` is in the ROOT folder (same level as index.html)
- Make sure `api/analyze.js` is in an `api` subfolder
- File structure should look exactly like:
  ```
  your-project/
  ├── index.html
  ├── vercel.json  ← Must be here!
  └── api/
      └── analyze.js  ← Must be here!
  ```
- Redeploy completely: `vercel --force`

### **Error: "CORS error"**
✅ **Fix:**
- This is fixed by vercel.json
- Make sure vercel.json was uploaded
- Clear browser cache and try again

### **Receipts upload but nothing happens**
✅ **Fix:**
- Open browser console (F12 → Console tab)
- Try uploading again
- Look for error messages
- Send me the exact error

---

## 📋 Checklist Before Testing

- [ ] All 3 files uploaded (index.html, vercel.json, api/analyze.js)
- [ ] Files in correct folders (api folder exists)
- [ ] Environment variable added (`ANTHROPIC_API_KEY`)
- [ ] Redeployed after adding API key
- [ ] Waited 30+ seconds after deploy

---

## 💰 Costs

Each receipt scan costs approximately:
- Small receipt (few items): $0.01-0.02
- Large receipt (many items): $0.03-0.05

**Monthly estimates:**
- 50 receipts: ~$1-2
- 200 receipts: ~$4-10
- 1000 receipts: ~$20-50

Monitor at: https://console.anthropic.com/settings/usage

---

## 🔒 Security

✅ Your API key is safe (stored server-side)
✅ Users can't see or steal it
✅ Only your domain can use it

---

## 📱 Data Storage

The app now uses:
- `localStorage` (browser storage) when deployed
- Data persists on each device
- NOT synced across devices (yet)

To add cloud sync later, we'd need to add:
- User authentication
- Database (Firebase/Supabase)
- Backend storage

---

## 🆘 Need Help?

If it still doesn't work:

1. **Check Vercel logs:**
   - Go to your project
   - Click "Deployments"
   - Click latest deployment
   - Click "View Function Logs"
   - Look for errors

2. **Check browser console:**
   - Press F12
   - Go to Console tab
   - Try uploading receipt
   - Screenshot any errors

3. **Tell me:**
   - Your Vercel URL
   - The exact error message
   - Screenshot of file structure on Vercel

I'll help you fix it! 🚀

---

## ✅ Success Indicators

You know it's working when:
- ✅ Page loads without errors
- ✅ Can upload receipt image
- ✅ See "Processing..." animation
- ✅ Items appear with prices
- ✅ Can save to budget
- ✅ Data appears on Dashboard

If all of these work, you're done! 🎉
