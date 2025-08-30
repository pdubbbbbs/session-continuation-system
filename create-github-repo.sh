#!/bin/bash

# GitHub Repository Creation Script for macOS 10.15+
# Alternative to GitHub CLI for older macOS versions

set -e  # Exit on any error

REPO_NAME="session-continuation-system"
REPO_DESCRIPTION="A comprehensive system for maintaining context and continuity across AI assistant sessions"

echo "🚀 GitHub Repository Creation Script"
echo "=================================="
echo ""

# Check if we have a GitHub token
if [ -z "$GITHUB_TOKEN" ]; then
    echo "❌ GitHub Personal Access Token required!"
    echo ""
    echo "To create a GitHub repository, you need a Personal Access Token."
    echo ""
    echo "📋 Setup Instructions:"
    echo "1. Go to https://github.com/settings/tokens"
    echo "2. Click 'Generate new token' -> 'Generate new token (classic)'"
    echo "3. Give it a name like 'Session Continuation System'"
    echo "4. Select scopes: 'repo' (Full control of private repositories)"
    echo "5. Click 'Generate token'"
    echo "6. Copy the token (you won't see it again!)"
    echo ""
    echo "Then run this script with your token:"
    echo "GITHUB_TOKEN=your_token_here ./create-github-repo.sh"
    echo ""
    echo "Or set it as an environment variable:"
    echo "export GITHUB_TOKEN=your_token_here"
    echo "./create-github-repo.sh"
    exit 1
fi

# Check if git is configured with user info
if [ -z "$(git config user.name)" ] || [ -z "$(git config user.email)" ]; then
    echo "❌ Git user configuration required!"
    echo ""
    echo "Please configure git with your GitHub credentials:"
    echo "git config --global user.name \"Your Name\""
    echo "git config --global user.email \"your.email@example.com\""
    exit 1
fi

# Get GitHub username from the token
echo "🔍 Verifying GitHub token..."
GITHUB_USER=$(curl -s -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/user | grep -o '"login":"[^"]*"' | cut -d'"' -f4)

if [ -z "$GITHUB_USER" ]; then
    echo "❌ Invalid GitHub token or API error!"
    echo "Please check your token and try again."
    exit 1
fi

echo "✅ Authenticated as: $GITHUB_USER"
echo ""

# Create the repository on GitHub
echo "📦 Creating repository '$REPO_NAME' on GitHub..."

# Check if repository already exists
REPO_EXISTS=$(curl -s -o /dev/null -w "%{http_code}" -H "Authorization: token $GITHUB_TOKEN" "https://api.github.com/repos/$GITHUB_USER/$REPO_NAME")

if [ "$REPO_EXISTS" = "200" ]; then
    echo "⚠️  Repository '$REPO_NAME' already exists!"
    echo "Would you like to push to the existing repository? (y/N)"
    read -r PUSH_EXISTING
    if [ "$PUSH_EXISTING" != "y" ] && [ "$PUSH_EXISTING" != "Y" ]; then
        echo "❌ Aborted."
        exit 1
    fi
    echo "📤 Will push to existing repository..."
else
    # Create new repository
    CREATE_RESPONSE=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
        -H "Content-Type: application/json" \
        -d "{
            \"name\": \"$REPO_NAME\",
            \"description\": \"$REPO_DESCRIPTION\",
            \"private\": false,
            \"has_issues\": true,
            \"has_projects\": true,
            \"has_wiki\": true
        }" \
        https://api.github.com/user/repos)

    # Check if creation was successful
    if echo "$CREATE_RESPONSE" | grep -q '"id"'; then
        echo "✅ Repository created successfully!"
    else
        echo "❌ Failed to create repository!"
        echo "Response: $CREATE_RESPONSE"
        exit 1
    fi
fi

# Add GitHub as remote origin (remove existing if present)
echo "🔗 Configuring remote origin..."
if git remote get-url origin >/dev/null 2>&1; then
    git remote remove origin
fi
git remote add origin "https://github.com/$GITHUB_USER/$REPO_NAME.git"

# Push to GitHub
echo "📤 Pushing code to GitHub..."
git branch -M main
git push -u origin main

echo ""
echo "🎉 SUCCESS!"
echo "=================================="
echo "Repository created and code pushed to GitHub!"
echo ""
echo "🔗 Repository URL: https://github.com/$GITHUB_USER/$REPO_NAME"
echo "📖 View online: https://github.com/$GITHUB_USER/$REPO_NAME"
echo ""
echo "🛠️  Next steps:"
echo "- Visit your repository to see the code"
echo "- Enable GitHub Pages if you want hosted docs"
echo "- Add topics/tags for discoverability"
echo "- Share the repository with others!"
echo ""
echo "💡 For future repositories, you can use this script with:"
echo "GITHUB_TOKEN=your_token ./create-github-repo.sh"
