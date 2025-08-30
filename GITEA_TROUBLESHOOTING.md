# 🚨 Gitea Server Troubleshooting

## Current Issue
Your Gitea server at `philipwright.me` is returning **Error 1033** (Cloudflare DNS resolution error).

## Error Details
- **Status**: HTTP 530
- **Cloudflare Error**: 1033 (DNS resolution error)
- **Meaning**: Origin server unreachable

## Troubleshooting Steps

### 1. Check Server Status
```bash
# Test connectivity
curl -I https://philipwright.me

# Check if it's just the web interface or the entire server
ping philipwright.me
```

### 2. Common Causes & Fixes

#### Server Down
- Check if your Gitea server process is running
- Restart Gitea service if needed:
  ```bash
  # On your server
  sudo systemctl status gitea
  sudo systemctl restart gitea
  ```

#### DNS Issues
- Verify DNS records point to correct IP
- Check Cloudflare DNS settings
- Ensure A/AAAA records are correct

#### Firewall/Security
- Check if firewall is blocking connections
- Verify Cloudflare proxy settings
- Ensure port 443/80 are open

#### Server Resources
- Check disk space
- Verify memory usage
- Look at server logs

### 3. Alternative Git Remotes (Temporary)

While fixing your Gitea server, you can use:

#### GitLab
```bash
# Add GitLab as temporary remote
git remote add gitlab https://gitlab.com/pdubbbbbs/session-continuation-system.git
git push gitlab main
```

#### Codeberg (Gitea-based)
```bash
# Add Codeberg as alternative
git remote add codeberg https://codeberg.org/pdubbbbbs/session-continuation-system.git  
git push codeberg main
```

#### Self-hosted alternatives
- Set up on different subdomain
- Use different port
- Temporary local GitLab/Gitea instance

## Quick Recovery Plan

### Immediate (5 minutes)
1. **Check server logs** for specific error messages
2. **Restart Gitea service** if server is accessible
3. **Verify DNS** records in Cloudflare dashboard

### Short-term (30 minutes)
1. **Use alternative remote** (GitLab/Codeberg) for current sync
2. **Investigate root cause** of server issue
3. **Monitor server health** once restored

### Long-term
1. **Set up monitoring** to catch issues early
2. **Create backup sync strategy** for future outages
3. **Document recovery procedures**

## When Gitea is Restored

Once your server is back online:
```bash
# Test connectivity
curl -I https://philipwright.me

# Run the Gitea creation script
GITEA_TOKEN=your_token ./create-gitea-repo.sh

# Or manually push
git push gitea main
```

## Current Repository Status
- ✅ **GitHub**: https://github.com/pdubbbbbs/session-continuation-system (WORKING)
- ❌ **Gitea**: https://philipwright.me/... (ERROR 1033 - SERVER DOWN)

---

**Priority**: Fix the Gitea server or use alternative remote for now.
