#!/bin/bash

# Cloudflare Tunnel Setup for Gitea
# Creates tunnel for Gitea running on https://alwaysunder.me:8001

set -e

TUNNEL_NAME="gitea-tunnel"
LOCAL_SERVICE="https://localhost:8001"
DOMAIN="alwaysunder.me"
SUBDOMAIN="git"
FULL_DOMAIN="$SUBDOMAIN.$DOMAIN"

echo "🌩️  Cloudflare Tunnel Setup for Gitea"
echo "===================================="
echo ""
echo "🎯 Target: $LOCAL_SERVICE"
echo "🌐 Public URL: https://$FULL_DOMAIN"
echo ""

# Check if already logged in
echo "🔑 Checking Cloudflare authentication..."
if cloudflared tunnel list >/dev/null 2>&1; then
    echo "✅ Already authenticated with Cloudflare"
else
    echo "🔐 Please authenticate with Cloudflare..."
    echo "This will open your browser for login."
    cloudflared tunnel login
fi

echo ""

# Check if tunnel already exists
echo "🔍 Checking for existing tunnels..."
EXISTING_TUNNEL=$(cloudflared tunnel list | grep "$TUNNEL_NAME" | awk '{print $1}' || true)

if [ -n "$EXISTING_TUNNEL" ]; then
    echo "⚠️  Tunnel '$TUNNEL_NAME' already exists (ID: $EXISTING_TUNNEL)"
    echo "Using existing tunnel..."
    TUNNEL_ID="$EXISTING_TUNNEL"
else
    echo "📦 Creating new tunnel '$TUNNEL_NAME'..."
    TUNNEL_OUTPUT=$(cloudflared tunnel create "$TUNNEL_NAME")
    TUNNEL_ID=$(echo "$TUNNEL_OUTPUT" | grep "Created tunnel" | awk '{print $4}')
    
    if [ -z "$TUNNEL_ID" ]; then
        echo "❌ Failed to create tunnel"
        echo "Output: $TUNNEL_OUTPUT"
        exit 1
    fi
    
    echo "✅ Tunnel created successfully!"
    echo "🆔 Tunnel ID: $TUNNEL_ID"
fi

echo ""

# Create tunnel configuration
echo "⚙️  Creating tunnel configuration..."
TUNNEL_CONFIG_DIR="$HOME/.cloudflared"
TUNNEL_CONFIG_FILE="$TUNNEL_CONFIG_DIR/config.yml"

mkdir -p "$TUNNEL_CONFIG_DIR"

cat > "$TUNNEL_CONFIG_FILE" << EOF
tunnel: $TUNNEL_ID
credentials-file: $TUNNEL_CONFIG_DIR/$TUNNEL_ID.json

ingress:
  - hostname: $FULL_DOMAIN
    service: $LOCAL_SERVICE
    originServerName: $FULL_DOMAIN
  - service: http_status:404
EOF

echo "✅ Configuration created at: $TUNNEL_CONFIG_FILE"

echo ""

# Route DNS
echo "🌐 Setting up DNS routing..."
if cloudflared tunnel route dns "$TUNNEL_ID" "$FULL_DOMAIN"; then
    echo "✅ DNS route created for $FULL_DOMAIN"
else
    echo "⚠️  DNS route may already exist or need manual setup"
fi

echo ""

# Test local service
echo "🧪 Testing local Gitea service..."
if curl -k -s -o /dev/null -w "%{http_code}" "$LOCAL_SERVICE" | grep -q "200\|302\|403"; then
    echo "✅ Local Gitea service is responding"
else
    echo "⚠️  Local Gitea service may not be running on $LOCAL_SERVICE"
    echo "Make sure Gitea is running before starting the tunnel"
fi

echo ""
echo "🎉 Tunnel Setup Complete!"
echo "========================"
echo ""
echo "📋 Configuration Summary:"
echo "├── Tunnel Name: $TUNNEL_NAME"
echo "├── Tunnel ID: $TUNNEL_ID"
echo "├── Local Service: $LOCAL_SERVICE"
echo "├── Public URL: https://$FULL_DOMAIN"
echo "└── Config File: $TUNNEL_CONFIG_FILE"
echo ""
echo "🚀 Next Steps:"
echo ""
echo "1. **Start the tunnel**:"
echo "   cloudflared tunnel --config $TUNNEL_CONFIG_FILE run"
echo ""
echo "2. **Or run as background service**:"
echo "   cloudflared tunnel --config $TUNNEL_CONFIG_FILE run &"
echo ""
echo "3. **Install as system service (recommended)**:"
echo "   sudo cloudflared service install"
echo ""
echo "4. **Test your Gitea**:"
echo "   Open: https://$FULL_DOMAIN"
echo ""
echo "5. **Update git remote**:"
echo "   git remote set-url gitea https://$FULL_DOMAIN/pdubbbbbs/session-continuation-system.git"
echo ""
echo "💡 Management Commands:"
echo "├── List tunnels: cloudflared tunnel list"
echo "├── Tunnel info: cloudflared tunnel info $TUNNEL_NAME"  
echo "├── Delete tunnel: cloudflared tunnel delete $TUNNEL_NAME"
echo "└── Service status: sudo launchctl list | grep cloudflared"
echo ""
echo "🔧 Troubleshooting:"
echo "├── Check logs: sudo tail -f /var/log/cloudflared.log"
echo "├── Restart service: sudo launchctl unload/load cloudflared"
echo "└── Test connection: curl -I https://$FULL_DOMAIN"
