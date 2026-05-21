set -e

echo "🛡️ Starting Security Audit (macOS)..."
echo "====================================="

# 1. Check Gatekeeper Status
echo "[CHECK] Checking Gatekeeper..."
GK_STATUS=$(spctl --assess --type execute --verbose /Applications/Safari.app 2>&1 | grep -i "rejected\|master enable")
if [[ "$GK_STATUS" == *"master enable"* ]]; then
    echo "🟢 OK: Gatekeeper is enabled."
else
    echo "🔴 WARNING: Gatekeeper might be disabled or modified."
fi

# 2. Check Remote Login (SSH)
echo "[CHECK] Checking Remote Login (SSH)..."
SSH_STATUS=$(systemsetup -getremotelogin | grep -i "on")
if [ -n "$SSH_STATUS" ]; then
    echo "🔴 WARNING: Remote Login (SSH) is ENABLED."
else
    echo "🟢 OK: Remote Login is OFF."
fi

# 3. Check Firewall
echo "[CHECK] Checking macOS Firewall..."
FW_STATUS=$(defaults read /Library/Preferences/com.apple.alf globalstate)
if [ "$FW_STATUS" -eq 0 ]; then
    echo "🔴 WARNING: Application Firewall is OFF."
else
    echo "🟢 OK: Application Firewall is ON."
fi

# 4. Check for open ports
echo "[CHECK] Listening ports..."
netstat -an | grep LISTEN | head -n 5

echo "====================================="
echo "✅ Security Audit Complete."