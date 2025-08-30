#!/bin/bash

# Script to sync Session Continuation System with Gitea instance
# Works with philipwright.me Gitea server

set -e

GITEA_URL="https://philipwright.me"
REPO_NAME="session-continuation-system"
REPO_DESCRIPTION="A comprehensive system for maintaining context and continuity across AI assistant sessions"

echo "🔄 Gitea Sync Setup for Session Continuation System"
echo "=================================================="
echo ""
echo "🎯 Target: $GITEA_URL"
echo "📦 Repository: $REPO_NAME"
echo ""

# Check if Gitea remote exists
if git remote get-url gitea >/dev/null 2>&1; then
    echo "✅ Gitea remote already configured"
    GITEA_REMOTE=$(git remote get-url gitea)
    echo "🔗 Remote: $GITEA_REMOTE"
else
    echo "🔗 Adding Gitea remote..."
    git remote add gitea "https://philipwright.me/pdubbbbbs/$REPO_NAME.git"
    echo "✅ Gitea remote added"
fi

echo ""
echo "📋 Next Steps:"
echo ""
echo "1. 🌐 **Create Repository on Gitea**:"
echo "   - Go to: $GITEA_URL"
echo "   - Log in to your account"
echo "   - Click '+' or 'New Repository'"
echo "   - Repository name: $REPO_NAME"
echo "   - Description: $REPO_DESCRIPTION"
echo "   - Make it public (recommended)"
echo "   - Do NOT initialize with README (we have files already)"
echo ""
echo "2. 🚀 **Push to Gitea** (run after creating the repository):"
echo "   git push gitea main"
echo ""
echo "3. 🔄 **Future Syncing** (push to both GitHub and Gitea):"
echo "   git push origin main    # Push to GitHub"
echo "   git push gitea main     # Push to Gitea"
echo "   # Or push to both at once:"
echo "   git push origin main && git push gitea main"
echo ""

# Try to push if repository might exist
echo "🧪 Testing connection to Gitea..."
if git ls-remote gitea >/dev/null 2>&1; then
    echo "✅ Repository exists on Gitea - pushing now..."
    git push gitea main
    echo ""
    echo "🎉 SUCCESS! Repository synced to Gitea!"
    echo "🔗 View at: $GITEA_URL/pdubbbbbs/$REPO_NAME"
else
    echo "⚠️  Repository doesn't exist on Gitea yet."
    echo "Please create it first using the steps above, then run:"
    echo "git push gitea main"
fi

echo ""
echo "📊 Current Remotes:"
git remote -v

echo ""
echo "💡 **Automation Tip**: After setup, you can create an alias:"
echo "git config alias.pushall '!git push origin main && git push gitea main'"
echo "Then use: git pushall"
