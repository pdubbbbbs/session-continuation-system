# ⚡ Quick GitHub Setup - Automated

Since GitHub CLI requires macOS 12+, I've created a script that uses the GitHub API directly.

## 🎯 **One-Time Setup (5 minutes)**

### Step 1: Create GitHub Personal Access Token
1. **Go to**: https://github.com/settings/tokens
2. **Click**: "Generate new token" → "Generate new token (classic)"
3. **Name it**: "Session Continuation System" 
4. **Select scope**: ☑️ `repo` (Full control of private repositories)
5. **Generate** and **copy the token** (save it somewhere safe!)

### Step 2: Configure Git (if not already done)
```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

## 🚀 **Automated Repository Creation**

Once you have your token, run this command:

```bash
GITHUB_TOKEN=your_token_here ./create-github-repo.sh
```

**Example**:
```bash
GITHUB_TOKEN=YOUR_GITHUB_TOKEN ./create-github-repo.sh
```

## 🎉 **What the Script Does**

1. ✅ **Verifies your GitHub token**
2. ✅ **Creates the repository** on GitHub with proper settings
3. ✅ **Configures git remote** to point to your new repo
4. ✅ **Pushes all code** to GitHub
5. ✅ **Gives you the repository URL**

## 🔒 **Security Note**

For security, you can also set the token as an environment variable:

```bash
export GITHUB_TOKEN=your_token_here
./create-github-repo.sh
```

This way the token won't be visible in your command history.

## ⚡ **Alternative: Manual 30-Second Setup**

If you prefer manual setup:

1. **Create repo** on GitHub.com (name: `session-continuation-system`)
2. **Run these commands**:
   ```bash
   git remote add origin https://github.com/YOUR_USERNAME/session-continuation-system.git
   git branch -M main  
   git push -u origin main
   ```

---

**Your repository is ready to go live with one command!** 🚀
