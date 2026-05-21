#!/bin/bash
# src/macos/security_audit.sh
# sysadmin-toolkit Module 4: Security Audit (macOS)
# Usage: ./security_audit.sh

set -e

echo "🛡️ Starting Security Audit (macOS)..."
echo "====================================="

echo "[CHECK] Checking Gatekeeper..."
if spctl --assess --type execute --verbose /Applications/Safari.app 2>&1 | grep -q "master enable"; then
    echo "🟢 OK: Gatekeeper is enabled."
else
    echo "🔴 WARNING: Gatekeeper might be disabled or modified."
fi

echo "[CHECK] Checking Remote Login (SSH)..."
if systemsetup -getremotelogin | grep -q "On"; then
    echo "🔴 WARNING: Remote Login (SSH) is ENABLED."
else
    echo "🟢 OK: Remote Login is OFF."
fi

echo "[CHECK] Checking macOS Firewall..."
FW_STATUS=$(defaults read /Library/Preferences/com.apple.alf globalstate 2>/dev/null)
if [ "$FW_STATUS" -eq 0 ]; then
    echo "🔴 WARNING: Application Firewall is OFF."
else
    echo "🟢 OK: Application Firewall is ON."
fi

echo "[CHECK] Listening ports..."
netstat -an | grep LISTEN | head -n 5

echo "====================================="
echo "✅ Security Audit Complete."