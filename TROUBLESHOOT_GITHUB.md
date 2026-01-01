# Troubleshooting GitHub Repository Creation

## Issue: "Unknown error" when creating repository from Xcode

### Solution 1: Create Repository on GitHub Website First (Recommended)

1. **Go to GitHub.com** and sign in
2. Click the **"+"** icon → **"New repository"**
3. Use a name **without spaces**: `bart-train-app` or `BARTTrainApp`
4. Choose Public or Private
5. **DO NOT** check "Initialize with README"
6. Click **"Create repository"**

7. **Then connect from command line:**

```bash
cd "/Users/fairwin/Downloads/Train Departure App Design (2)"

# Add all files
git add .

# Commit
git commit -m "Initial commit: BART Departure App"

# Add remote (replace YOUR_USERNAME with your GitHub username)
git remote add origin https://github.com/FairwinLi/bart-train-app.git

# Set main branch
git branch -M main

# Push
git push -u origin main
```

### Solution 2: Fix Repository Name (No Spaces)

If you want to create via Xcode/interface:
- Change repository name from "BART TRAIN APP" to "BART-TRAIN-APP" or "bart-train-app"
- Spaces in repository names can cause issues

### Solution 3: Check Authentication

1. Make sure you're logged into GitHub
2. Check if you need to authenticate:
   - GitHub → Settings → Developer settings → Personal access tokens
   - Generate a token with `repo` scope
   - Use this token as password when pushing

### Solution 4: Use Command Line (Most Reliable)

The command line is usually more reliable than GUI tools. Follow Solution 1 above.

