#!/bin/bash

# Multi-Remote Sync Strategy
# Pushes to multiple git remotes with proper authentication

set -e

echo "🔄 Multi-Remote Git Sync"
echo "======================="
echo ""

# Current remotes status
echo "📊 Current Remote Status:"
echo "├── GitHub (origin): ✅ WORKING"
echo "├── Gitea: ❌ DOWN (Error 1033)"
echo "└── GitLab: ⚠️ NEEDS SETUP"
echo ""

# Push to GitHub (already working)
echo "📤 Pushing to GitHub..."
if git push origin main; then
    echo "✅ GitHub sync successful!"
else
    echo "❌ GitHub sync failed"
    exit 1
fi

echo ""

# Check Gitea server status
echo "🔍 Checking Gitea server..."
GITEA_STATUS=$(curl -s -o /dev/null -w "%{http_code}" https://philipwright.me 2>/dev/null || echo "000")

if [ "$GITEA_STATUS" = "200" ]; then
    echo "✅ Gitea server is back online!"
    echo "📤 Attempting Gitea sync..."
    
    if [ -n "$GITEA_TOKEN" ]; then
        # Use automated script if token available
        ./create-gitea-repo.sh
    else
        echo "ℹ️  Run with GITEA_TOKEN to use automated sync:"
        echo "GITEA_TOKEN=your_token ./multi-remote-sync.sh"
        echo ""
        echo "Or manually push:"
        echo "git push gitea main"
    fi
else
    echo "❌ Gitea server still down (HTTP $GITEA_STATUS)"
    echo "ℹ️  Will retry Gitea when server is restored"
fi

echo ""
echo "🎯 Repository Status:"
echo "├── GitHub: https://github.com/pdubbbbbs/session-continuation-system ✅"

if [ "$GITEA_STATUS" = "200" ]; then
    echo "├── Gitea: https://philipwright.me/pdubbbbbs/session-continuation-system ✅"
else
    echo "├── Gitea: https://philipwright.me/pdubbbbbs/session-continuation-system ❌"
fi

echo ""
echo "💡 Next Steps:"
echo "1. ✅ Your code is safely backed up on GitHub"
echo "2. 🔧 Fix Gitea server when convenient"
echo "3. 🔄 Run this script again when Gitea is restored"

# Optional: Setup additional backup remotes
echo ""
echo "🛟 Optional Additional Backups:"
echo ""
echo "For GitLab (create token at https://gitlab.com/-/profile/personal_access_tokens):"
echo "git remote add gitlab https://gitlab.com/pdubbbbbs/session-continuation-system.git"
echo "git push gitlab main"
echo ""
echo "For Codeberg (Gitea-based alternative):"
echo "git remote add codeberg https://codeberg.org/pdubbbbbs/session-continuation-system.git"  
echo "git push codeberg main"
