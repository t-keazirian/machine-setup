#!/bin/bash
export PATH="/opt/homebrew/bin:$PATH"
set -euo pipefail

LOG_FILE=~/Scripts/brew-maintenance-simple.log

echo "========================================" | tee -a "$LOG_FILE"
echo " Homebrew maintenance started at $(date) " | tee -a "$LOG_FILE"
echo "========================================" | tee -a "$LOG_FILE"

{
  echo
  echo "---- brew update ----"
  brew update -v || echo "brew update failed. Continuing..." >&2

  echo
  echo "---- brew upgrade ----"
  brew upgrade -v || echo "brew upgrade had failures. Continuing..."

  echo
  echo "---- brew upgrade --cask ----"
  brew upgrade --cask -v || echo "brew upgrade --cask had failures. Continuing..."

  echo
  echo "---- brew doctor ----"
  brew doctor || true
} 2>&1 | tee -a "$LOG_FILE"

echo
echo "========================================" | tee -a "$LOG_FILE"
echo " Checking what cleanup would remove (dry run) " | tee -a "$LOG_FILE"
echo "========================================" | tee -a "$LOG_FILE"
brew cleanup --dry-run --prune=all 2>&1 | tee -a "$LOG_FILE"

echo
echo "========================================" | tee -a "$LOG_FILE"
read -p "Do you want to run 'brew cleanup --prune=all' now? [y/N] " -r
if [[ $REPLY =~ ^[Yy]$ ]]; then
  echo "---- Running brew cleanup --prune=all ----" | tee -a "$LOG_FILE"
  brew cleanup --prune=all 2>&1 | tee -a "$LOG_FILE"
  echo "Cleanup completed at $(date)" | tee -a "$LOG_FILE"
else
  echo "Cleanup skipped" | tee -a "$LOG_FILE"
fi

echo
echo "========================================" | tee -a "$LOG_FILE"
echo " Homebrew maintenance completed at $(date) " | tee -a "$LOG_FILE"
echo "========================================" | tee -a "$LOG_FILE"
