#!/bin/bash
# src/linux/security_audit.sh
# sysadmin-toolkit Module 4: Security Audit (Linux)
# Usage: ./security_audit.sh [--verbose]

set -e

VERBOSE=false
if [[ "$1" == "--verbose" ]]; then
    VERBOSE=true
fi

echo "🛡️ Starting Security Audit (Linux)..."
echo "====================================="

echo "[CHECK] Checking for empty passwords..."
EMPTY_PASS=$(awk -F: '($2 == "") {print $1}' /etc/shadow 2>/dev/null)
if [ -n "$EMPTY_PASS" ]; then
    echo "🔴 CRITICAL: Accounts with empty passwords found: $EMPTY_PASS"
else
    echo "🟢 OK: No accounts with empty passwords."
fi

echo "[CHECK] Checking for UID 0 users..."
awk -F: '($3 == 0 && $1 != "root") {print " CRITICAL: Non-root user has UID 0: " $1}' /etc/passwd

echo "[CHECK] Checking SSH configuration..."
SSH_CONFIG="/etc/ssh/sshd_config"
if [ -f "$SSH_CONFIG" ]; then
    ROOT_LOGIN=$(grep -i "^PermitRootLogin" "$SSH_CONFIG" | awk '{print $2}')
    if [ "$ROOT_LOGIN" == "yes" ]; then
        echo "🔴 WARNING: SSH Root Login is ENABLED."
    else
        echo "🟢 OK: SSH Root Login is restricted ($ROOT_LOGIN)."
    fi
else
    echo "⚪ INFO: SSH configuration file not found."
fi

echo "[CHECK] Listing listening ports..."
if command -v ss &> /dev/null; then
    ss -tuln | head -n 5
else
    netstat -tuln 2>/dev/null | head -n 5
fi

echo "[CHECK] Checking Firewall status..."
if command -v ufw &> /dev/null; then
    ufw status | head -n 1
elif command -v firewall-cmd &> /dev/null; then
    firewall-cmd --state
else
    echo "⚠️ No standard firewall (UFW/Firewalld) detected."
fi

echo "====================================="
echo "✅ Security Audit Complete."