#!/bin/bash

# Automated Gitea Repository Creation Script
# Creates repository on philipwright.me Gitea instance

set -e

GITEA_URL="https://philipwright.me"
GITEA_API_URL="$GITEA_URL/api/v1"
REPO_NAME="session-continuation-system"
REPO_DESCRIPTION="A comprehensive system for maintaining context and continuity across AI assistant sessions"

echo "🏠 Gitea Repository Creation Script"
echo "================================="
echo ""
echo "🎯 Target: $GITEA_URL"
echo "📦 Repository: $REPO_NAME"
echo ""

# Check if we have a Gitea token
if [ -z "$GITEA_TOKEN" ]; then
    echo "❌ Gitea Access Token required!"
    echo ""
    echo "To create a Gitea repository automatically, you need an access token."
    echo ""
    echo "📋 Setup Instructions:"
    echo "1. Go to: $GITEA_URL/user/settings/applications"
    echo "2. Click 'Generate New Token'"
    echo "3. Give it a name like 'Session Continuation System'"
    echo "4. Select scopes: 'repository' permissions"
    echo "5. Click 'Generate Token'"
    echo "6. Copy the token"
    echo ""
    echo "Then run this script with your token:"
    echo "GITEA_TOKEN=your_token_here ./create-gitea-repo.sh"
    echo ""
    echo "Or set it as an environment variable:"
    echo "export GITEA_TOKEN=your_token_here"
    echo "./create-gitea-repo.sh"
    exit 1
fi

# Get Gitea user info from the token
echo "🔍 Verifying Gitea token..."
GITEA_USER_INFO=$(curl -s -H "Authorization: token $GITEA_TOKEN" "$GITEA_API_URL/user")

if echo "$GITEA_USER_INFO" | grep -q '"login"'; then
    GITEA_USER=$(echo "$GITEA_USER_INFO" | python3 -c "import sys, json; print(json.load(sys.stdin)['login'])" 2>/dev/null)
    echo "✅ Authenticated as: $GITEA_USER"
else
    echo "❌ Invalid Gitea token or API error!"
    echo "Response: $GITEA_USER_INFO"
    exit 1
fi

echo ""

# Check if repository already exists
echo "📦 Checking if repository exists..."
REPO_EXISTS=$(curl -s -o /dev/null -w "%{http_code}" -H "Authorization: token $GITEA_TOKEN" "$GITEA_API_URL/repos/$GITEA_USER/$REPO_NAME")

if [ "$REPO_EXISTS" = "200" ]; then
    echo "⚠️  Repository '$REPO_NAME' already exists on Gitea!"
    echo "Proceeding to push to existing repository..."
else
    echo "📦 Creating repository '$REPO_NAME' on Gitea..."
    
    # Create new repository
    CREATE_RESPONSE=$(curl -s -H "Authorization: token $GITEA_TOKEN" \
        -H "Content-Type: application/json" \
        -d "{
            \"name\": \"$REPO_NAME\",
            \"description\": \"$REPO_DESCRIPTION\",
            \"private\": false,
            \"auto_init\": false,
            \"gitignores\": \"\",
            \"license\": \"MIT\",
            \"readme\": \"\"
        }" \
        "$GITEA_API_URL/user/repos")

    # Check if creation was successful
    if echo "$CREATE_RESPONSE" | grep -q '"id"'; then
        echo "✅ Repository created successfully on Gitea!"
    else
        echo "❌ Failed to create repository on Gitea!"
        echo "Response: $CREATE_RESPONSE"
        exit 1
    fi
fi

# Configure git remote if not already done
echo "🔗 Configuring Gitea remote..."
if git remote get-url gitea >/dev/null 2>&1; then
    echo "✅ Gitea remote already configured"
else
    git remote add gitea "$GITEA_URL/$GITEA_USER/$REPO_NAME.git"
    echo "✅ Gitea remote added"
fi

# Push to Gitea
echo "📤 Pushing code to Gitea..."
if git push gitea main; then
    echo ""
    echo "🎉 SUCCESS!"
    echo "================================="
    echo "Repository created and code pushed to Gitea!"
    echo ""
    echo "🔗 Repository URL: $GITEA_URL/$GITEA_USER/$REPO_NAME"
    echo "📖 View online: $GITEA_URL/$GITEA_USER/$REPO_NAME"
    echo ""
    echo "🔄 Your repository is now synced to both:"
    echo "- GitHub: https://github.com/pdubbbbbs/$REPO_NAME"
    echo "- Gitea:  $GITEA_URL/$GITEA_USER/$REPO_NAME"
    echo ""
    echo "💡 Future syncing:"
    echo "git pushall    # Push to both remotes"
    echo "git push origin main && git push gitea main"
else
    echo "❌ Failed to push to Gitea"
    echo "You may need to authenticate. Try running:"
    echo "git push gitea main"
fi
