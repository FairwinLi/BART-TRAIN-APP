#!/bin/bash

# Script to push BART Departure App to GitHub
# Usage: ./PUSH_TO_GITHUB.sh YOUR_GITHUB_USERNAME REPO_NAME

set -e

GITHUB_USER="${1:-FairwinLi}"
REPO_NAME="${2:-bart-train-app}"

echo "🚀 Setting up GitHub repository..."
echo "Repository: https://github.com/${GITHUB_USER}/${REPO_NAME}"

# Check if git is initialized
if [ ! -d .git ]; then
    echo "Initializing git repository..."
    git init
fi

# Add all files
echo "Adding files..."
git add .

# Check if there are changes to commit
if git diff --staged --quiet; then
    echo "No changes to commit. Checking existing commits..."
    if git log -1 > /dev/null 2>&1; then
        echo "Repository already has commits."
    else
        echo "⚠️  No commits found. Creating initial commit..."
        git commit -m "Initial commit: BART Departure App with real-time data and widgets"
    fi
else
    echo "Committing changes..."
    git commit -m "Initial commit: BART Departure App with real-time data and widgets"
fi

# Set branch to main
git branch -M main

# Check if remote exists
if git remote get-url origin > /dev/null 2>&1; then
    echo "Remote 'origin' already exists. Updating..."
    git remote set-url origin "https://github.com/${GITHUB_USER}/${REPO_NAME}.git"
else
    echo "Adding remote..."
    git remote add origin "https://github.com/${GITHUB_USER}/${REPO_NAME}.git"
fi

echo ""
echo "✅ Repository is ready to push!"
echo ""
echo "📋 Next steps:"
echo "1. Go to https://github.com/new"
echo "2. Create a repository named: ${REPO_NAME}"
echo "3. DO NOT initialize with README, .gitignore, or license"
echo "4. Then run: git push -u origin main"
echo ""
echo "Or if the repository already exists, run:"
echo "  git push -u origin main"

