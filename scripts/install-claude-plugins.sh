#!/usr/bin/env bash
set -euo pipefail

# ── install-claude-plugins.sh ──────────────────────────────────────────────────
# Declaratively installs and enables Claude Code plugins for personal and/or
# work contexts. Idempotent — safe to re-run on an already-configured machine.
#
# Personal context: driven by PERSONAL_PLUGINS (source of truth for fresh machines).
# Work context: derived automatically from personal's installed_plugins.json,
#   minus anything in PERSONAL_ONLY. Adding a plugin to personal and re-running
#   syncs it to work with no script edits required.
#
# Usage:
#   bash scripts/install-claude-plugins.sh [--context personal|work|both]
#
# Defaults to --context both.
# ──────────────────────────────────────────────────────────────────────────────

CONTEXT="both"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --context)
      CONTEXT="$2"
      shift 2
      ;;
    *)
      echo "Unknown argument: $1" >&2
      exit 1
      ;;
  esac
done

if [[ "$CONTEXT" != "personal" && "$CONTEXT" != "work" && "$CONTEXT" != "both" ]]; then
  echo "Error: --context must be personal, work, or both" >&2
  exit 1
fi

# ── Config dirs ───────────────────────────────────────────────────────────────
PERSONAL_DIR="$HOME/.claude"
WORK_DIR="$HOME/.claude-work"
PERSONAL_REGISTRY="$PERSONAL_DIR/plugins/installed_plugins.json"

# ── Color helpers ─────────────────────────────────────────────────────────────
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
RESET='\033[0m'

info() { echo -e "${BOLD}[plugins]${RESET} $*"; }
ok()   { echo -e "${GREEN}  ✔${RESET} $*"; }
warn() { echo -e "${YELLOW}  ⚠${RESET} $*"; }

# ── Plugin lists ──────────────────────────────────────────────────────────────
# Source of truth for what should be installed on a fresh personal context.
PERSONAL_PLUGINS=(
  "superpowers@claude-plugins-official"
  "github@claude-plugins-official"
  "code-simplifier@claude-plugins-official"
  "pr-review-toolkit@claude-plugins-official"
  "code-review@claude-plugins-official"
  "claude-md-management@claude-plugins-official"
  "claude-code-setup@claude-plugins-official"
  "explanatory-output-style@claude-plugins-official"
  "crafter@craft"
  "commit-commands@claude-plugins-official"
  "hookify@claude-plugins-official"
  "ralph-loop@claude-plugins-official"
  "frontend-design@claude-plugins-official"
  "typescript-lsp@claude-plugins-official"
  "pyright-lsp@claude-plugins-official"
  "skill-creator@claude-plugins-official"
  "safety-net@cc-marketplace"
)

# Plugins that must not be synced to the work context.
PERSONAL_ONLY=(
  "safety-net@cc-marketplace"
)

# ── Personal context ──────────────────────────────────────────────────────────
if [[ "$CONTEXT" == "personal" || "$CONTEXT" == "both" ]]; then
  info "Personal context ($PERSONAL_DIR)"

  # claude-plugins-official is registered by default; only add additional marketplaces.
  warn "Adding marketplace: cc-marketplace"
  CLAUDE_CONFIG_DIR="$PERSONAL_DIR" claude plugin marketplace add cc-marketplace kenryu42/cc-marketplace
  ok "Marketplace: cc-marketplace"

  warn "Adding marketplace: craft"
  CLAUDE_CONFIG_DIR="$PERSONAL_DIR" claude plugin marketplace add craft agentpatterns/craft
  ok "Marketplace: craft"

  for plugin in "${PERSONAL_PLUGINS[@]}"; do
    warn "Installing: $plugin"
    CLAUDE_CONFIG_DIR="$PERSONAL_DIR" claude plugin install "$plugin"
    CLAUDE_CONFIG_DIR="$PERSONAL_DIR" claude plugin enable "$plugin"
    ok "$plugin"
  done

  ok "Personal context complete."
fi

# ── Work context ──────────────────────────────────────────────────────────────
if [[ "$CONTEXT" == "work" || "$CONTEXT" == "both" ]]; then
  info "Work context ($WORK_DIR)"

  if [[ ! -f "$PERSONAL_REGISTRY" ]]; then
    echo "Error: personal registry not found at $PERSONAL_REGISTRY" >&2
    echo "Run with --context personal first, or install personal plugins before work." >&2
    exit 1
  fi

  warn "Adding marketplace: craft"
  CLAUDE_CONFIG_DIR="$WORK_DIR" claude plugin marketplace add craft agentpatterns/craft
  ok "Marketplace: craft"

  # Derive work plugin list from personal registry, excluding PERSONAL_ONLY.
  mapfile -t ALL_PERSONAL < <(jq -r '.plugins | keys[]' "$PERSONAL_REGISTRY")

  for plugin in "${ALL_PERSONAL[@]}"; do
    # Skip personal-only plugins.
    skip=false
    for excluded in "${PERSONAL_ONLY[@]}"; do
      if [[ "$plugin" == "$excluded" ]]; then
        skip=true
        break
      fi
    done
    [[ "$skip" == true ]] && continue

    warn "Installing: $plugin"
    CLAUDE_CONFIG_DIR="$WORK_DIR" claude plugin install "$plugin"
    CLAUDE_CONFIG_DIR="$WORK_DIR" claude plugin enable "$plugin"
    ok "$plugin"
  done

  ok "Work context complete."
fi

info "All done."
