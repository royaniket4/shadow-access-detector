#!/bin/bash

# ✅ CONFIG — Customize these
GIT_USERNAME="royaniket4"
GIT_EMAIL="aniket@example.com"
REPO_URL="https://github.com/royaniket4/shadow-access-detector.git"
COMMIT_MSG="Initial commit: full folder structure"

# ✅ Step 1: Set Git Identity
echo "🔧 Setting Git identity..."
git config --global user.name "$GIT_USERNAME"
git config --global user.email "$GIT_EMAIL"

# ✅ Step 2: Init Git (if not already)
if [ ! -d .git ]; then
  echo "📦 Initializing Git repo..."
  git init
else
  echo "📦 Git repo already initialized."
fi

# ✅ Step 3: Add Files
echo "📂 Adding files..."
git add .

# ✅ Step 4: Commit
echo "📝 Committing..."
git commit -m "$COMMIT_MSG" || echo "⚠️ No changes to commit."

# ✅ Step 5: Remote Setup
if git remote | grep origin > /dev/null; then
  echo "🔁 Remote 'origin' already exists. Replacing..."
  git remote remove origin
fi
git remote add origin "$REPO_URL"

# ✅ Step 6: Push
echo "🚀 Pushing to GitHub..."
git branch -M main
git push -u origin main

echo "✅ Done! Project pushed to GitHub."
