# 🌐 Cloudflare DNS Setup for Gitea Tunnel

## Current Status
- ✅ **Tunnel Created**: `gitea-tunnel` (ID: `16e91b23-0ebf-40b4-b828-af71e1b287b7`)
- ✅ **Tunnel Running**: 4 connections established
- ⚠️  **DNS Issue**: Route created under wrong domain

## DNS Configuration Issue

Cloudflare created: `git.alwaysunder.me.philipwright.me` ❌  
We need: `git.alwaysunder.me` ✅

## Manual DNS Setup Required

### Option 1: Cloudflare Dashboard (Recommended)

1. **Go to Cloudflare Dashboard**: https://dash.cloudflare.com
2. **Select `alwaysunder.me` domain**
3. **Go to DNS Records**
4. **Add CNAME Record**:
   - **Type**: CNAME
   - **Name**: `git`
   - **Target**: `16e91b23-0ebf-40b4-b828-af71e1b287b7.cfargotunnel.com`
   - **Proxy Status**: Proxied (orange cloud)

### Option 2: CLI Commands (if you have Cloudflare API token)

```bash
# Set your Cloudflare API token
export CLOUDFLARE_API_TOKEN="your_api_token_here"

# Add DNS record
curl -X POST "https://api.cloudflare.com/client/v4/zones/ZONE_ID/dns_records" \
  -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
  -H "Content-Type: application/json" \
  --data '{
    "type": "CNAME",
    "name": "git",
    "content": "16e91b23-0ebf-40b4-b828-af71e1b287b7.cfargotunnel.com",
    "proxied": true
  }'
```

## Tunnel Configuration

### Current Config: `/Users/fuckyou22/.cloudflared/config.yml`
```yaml
tunnel: 16e91b23-0ebf-40b4-b828-af71e1b287b7
credentials-file: /Users/fuckyou22/.cloudflared/16e91b23-0ebf-40b4-b828-af71e1b287b7.json

ingress:
  - hostname: git.alwaysunder.me
    service: https://localhost:8001
    originServerName: git.alwaysunder.me
  - service: http_status:404
```

### Tunnel Status
```bash
# Check if tunnel is running
cloudflared tunnel list
cloudflared tunnel info gitea-tunnel

# View current process
jobs
ps aux | grep cloudflared
```

## Testing Connection

Once DNS is configured (may take a few minutes to propagate):

```bash
# Test DNS resolution
nslookup git.alwaysunder.me
dig git.alwaysunder.me

# Test HTTPS connection
curl -I https://git.alwaysunder.me

# Test in browser
open https://git.alwaysunder.me
```

## Update Git Remote

Once the tunnel is working:

```bash
# Update gitea remote to use new domain
git remote set-url gitea https://git.alwaysunder.me/pdubbbbbs/session-continuation-system.git

# Test git connection
git ls-remote gitea
```

## Tunnel Management

### Start/Stop Tunnel
```bash
# Start tunnel (current running as background job)
cloudflared tunnel --config ~/.cloudflared/config.yml run

# Stop current background tunnel
kill %1

# Install as system service (recommended)
sudo cloudflared service install
sudo launchctl load com.cloudflare.cloudflared
```

### Logs and Troubleshooting
```bash
# View tunnel logs (if running as service)
sudo tail -f /var/log/cloudflared.log

# Check service status
sudo launchctl list | grep cloudflared

# Test local Gitea service
curl -k https://localhost:8001
```

## Next Steps

1. ✅ **DNS Setup**: Add CNAME record in Cloudflare dashboard
2. ⏳ **DNS Propagation**: Wait 5-10 minutes for DNS to propagate
3. 🧪 **Test Access**: Visit https://git.alwaysunder.me
4. 🔗 **Update Git Remote**: Point to new tunnel domain
5. 🚀 **Push Code**: Test git push to tunnel

## Expected Outcome

Once DNS is configured:
- **Public URL**: https://git.alwaysunder.me
- **Local Service**: https://localhost:8001 (your Gitea)
- **Secure**: All traffic encrypted through Cloudflare tunnel
- **No Firewall Issues**: No need to open ports or configure firewalls
