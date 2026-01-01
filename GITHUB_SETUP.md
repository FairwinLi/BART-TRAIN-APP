# How to Push to GitHub

## Step 1: Initialize Git Repository

Open Terminal and navigate to your project:

```bash
cd "/Users/fairwin/Downloads/Train Departure App Design (2)"
```

## Step 2: Initialize Git (if not already done)

```bash
git init
```

## Step 3: Add All Files

```bash
git add .
```

## Step 4: Create Initial Commit

```bash
git commit -m "Initial commit: BART Departure App with real-time data and widgets"
```

## Step 5: Create GitHub Repository

1. Go to [GitHub.com](https://github.com) and sign in
2. Click the **"+"** icon in the top right → **"New repository"**
3. Fill in:
   - **Repository name**: `bart-departure-app` (or your preferred name)
   - **Description**: "iOS BART train departure app with real-time data and widgets"
   - **Visibility**: Choose Public or Private
   - **DO NOT** initialize with README, .gitignore, or license (we already have files)
4. Click **"Create repository"**

## Step 6: Connect Local Repository to GitHub

GitHub will show you commands. Use these (replace `YOUR_USERNAME` with your GitHub username):

```bash
git remote add origin https://github.com/YOUR_USERNAME/bart-departure-app.git
git branch -M main
git push -u origin main
```

## Alternative: Using SSH (if you have SSH keys set up)

If you prefer SSH:

```bash
git remote add origin git@github.com:YOUR_USERNAME/bart-departure-app.git
git branch -M main
git push -u origin main
```

## Step 7: Verify

Go to your GitHub repository page - you should see all your files!

---

## Future Updates

When you make changes and want to push updates:

```bash
git add .
git commit -m "Description of your changes"
git push
```

---

## Troubleshooting

### "Repository not found" error
- Make sure you've created the repository on GitHub first
- Check that the repository name matches exactly
- Verify your GitHub username is correct

### "Permission denied" error
- You may need to authenticate. GitHub now requires a Personal Access Token instead of password
- Go to GitHub → Settings → Developer settings → Personal access tokens → Generate new token
- Use the token as your password when pushing

### Want to exclude certain files?
- Edit `.gitignore` file to add patterns for files you don't want to track
- Common exclusions: `*.xcuserstate`, `DerivedData/`, etc.

