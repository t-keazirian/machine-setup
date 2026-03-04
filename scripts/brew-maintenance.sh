#!/bin/bash
export PATH="/opt/homebrew/bin:$PATH"
set -euo pipefail  # Ensures script stops on errors

LOCKFILE="/tmp/brew-maintenance.lock"

# Prevent script from running twice
if [ -e "$LOCKFILE" ]; then
  echo "Script is already running. Exiting."
  exit 1
fi

# Create lock file
touch "$LOCKFILE"

# Ensure lock file is removed when script exits
trap 'rm -f "$LOCKFILE"' EXIT

LOG_DIR=~/Scripts
LOG_FILE="$LOG_DIR/brew-maintenance.log"
MAX_LOGS=5
LOG_NAME="brew-maintenance.log"

# Rotate logs (keeps only the last 5)
if [ -f "$LOG_DIR/$LOG_NAME" ]; then
  log_count=$(ls -1 $LOG_DIR | grep -E "$LOG_NAME.*" | wc -l)
  if [ "$log_count" -ge "$MAX_LOGS" ]; then
    oldest_log=$(ls -t $LOG_DIR/$LOG_NAME* | tail -1)
    rm -f "$oldest_log"
  fi
fi

echo "Starting Homebrew maintenance at $(date)..." | tee -a $LOG_FILE

# Check VPN connection (currently commented out)
# VPN_NAME="your-vpn-name"  # Replace with your actual VPN name
# if ! /usr/sbin/scutil --nc status "$VPN_NAME" | grep -q "Connected"; then
#     echo "VPN is not connected. Skipping VPN-dependent updates." | tee -a $LOG_FILE
# else
#     echo "VPN is connected. Proceeding with Homebrew updates." | tee -a $LOG_FILE

    {
        echo "============================="
        echo "Running: brew update -v"
        brew update -v
        echo "============================="
    } | tee -a $LOG_FILE
# fi

{
    echo "============================="
    echo "Running: brew upgrade --greedy -v"
    UPGRADE_OUTPUT=$(brew upgrade --greedy -v 2>&1)
    if [[ -z "$UPGRADE_OUTPUT" ]]; then
        echo "✅ No outdated formulae found."
    else
        echo "$UPGRADE_OUTPUT"
    fi
    echo "============================="
} | tee -a $LOG_FILE

{
    echo "============================="
    echo "Running: brew upgrade --cask -v"
    CASK_UPGRADE_OUTPUT=$(brew upgrade --cask -v 2>&1)
    if [[ -z "$CASK_UPGRADE_OUTPUT" ]]; then
        echo "✅ No outdated casks found."
    else
        echo "$CASK_UPGRADE_OUTPUT"
    fi
    echo "============================="
} | tee -a $LOG_FILE

{
    echo "============================="
    echo "Running: brew cleanup --prune=all"
    brew cleanup --prune=all
    echo "============================="
} | tee -a $LOG_FILE

{
    echo "============================="
    echo "Running: brew autoremove"
    brew autoremove
    echo "============================="
} | tee -a $LOG_FILE

{
    echo "============================="
    echo "Running: brew doctor"
    brew doctor
    echo "============================="
} | tee -a $LOG_FILE

{
    echo "============================="
    echo "Running: brew outdated"
    brew outdated
    echo "============================="
} | tee -a $LOG_FILE

echo "Homebrew maintenance completed at $(date)!" | tee -a $LOG_FILE
