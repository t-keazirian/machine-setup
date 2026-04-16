#!/usr/bin/env bash
# Removes packages that were pruned from the Brewfile.
# Safe to run on any machine — skips anything not installed.

set -uo pipefail

BOLD='\033[1m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RESET='\033[0m'

info() { echo -e "\n${BOLD}$*${RESET}"; }
ok()   { echo -e "  ${GREEN}✔${RESET} removed $*"; }
skip() { echo -e "  · $* — not installed, skipping"; }
warn() { echo -e "  ${YELLOW}⚠${RESET} failed to remove $*"; }

brew_remove() {
  local pkg="$1"
  if brew list --formula 2>/dev/null | grep -q "^${pkg}$"; then
    brew uninstall --ignore-dependencies "$pkg" &>/dev/null && ok "$pkg" || warn "$pkg"
  else
    skip "$pkg"
  fi
}

cask_remove() {
  local pkg="$1"
  if brew list --cask 2>/dev/null | grep -q "^${pkg}$"; then
    brew uninstall --cask "$pkg" &>/dev/null && ok "$pkg" || warn "$pkg"
  else
    skip "$pkg"
  fi
}

vscode_remove() {
  local ext="$1"
  if code --list-extensions 2>/dev/null | grep -qi "^${ext}$"; then
    code --uninstall-extension "$ext" &>/dev/null && ok "$ext" || warn "$ext"
  else
    skip "$ext"
  fi
}

# ── Homebrew formulae ──────────────────────────────────────────────────────────
info "Removing Homebrew formulae"
brew_remove awscli
brew_remove azure-cli
brew_remove cmake
brew_remove direnv
brew_remove elixir
brew_remove go
brew_remove kafka
brew_remove kcat
brew_remove k9s
brew_remove kubectx
brew_remove kubernetes-cli
brew_remove maven
brew_remove maven-completion
brew_remove "mysql@8.0"
brew_remove openjdk
brew_remove pandoc
brew_remove ruby
brew_remove swagger-codegen
brew_remove "vault"

# ── Homebrew taps ──────────────────────────────────────────────────────────────
info "Removing Homebrew taps"
for tap in hashicorp/tap sdkman/tap; do
  if brew tap | grep -q "^${tap}$"; then
    brew untap "$tap" &>/dev/null && ok "$tap" || warn "$tap"
  else
    skip "$tap"
  fi
done

# ── Casks ──────────────────────────────────────────────────────────────────────
info "Removing casks"
cask_remove codex
cask_remove datagrip
cask_remove dbeaver-community
cask_remove jetbrains-toolbox
cask_remove slack

# ── VS Code extensions ─────────────────────────────────────────────────────────
info "Removing VS Code extensions"
if ! command -v code &>/dev/null; then
  echo "  · VS Code CLI not found — skipping extensions"
else
  vscode_remove adpyke.vscode-sql-formatter
  vscode_remove alexkrechik.cucumberautocomplete
  vscode_remove andys8.jest-snippets
  vscode_remove angular.ng-template
  vscode_remove azemoh.one-monokai
  vscode_remove azemoh.theme-onedark
  vscode_remove bradlc.vscode-tailwindcss
  vscode_remove burkeholland.simple-react-snippets
  vscode_remove chakrounanas.turbo-console-log
  vscode_remove christian-kohler.npm-intellisense
  vscode_remove codezombiech.gitignore
  vscode_remove davidanson.vscode-markdownlint
  vscode_remove dbaeumer.vscode-eslint
  vscode_remove docker.docker
  vscode_remove donjayamanne.python-extension-pack
  vscode_remove dracula-theme.theme-dracula
  vscode_remove dsznajder.es7-react-js-snippets
  vscode_remove eamodio.gitlens
  vscode_remove ecmel.vscode-html-css
  vscode_remove editorconfig.editorconfig
  vscode_remove esbenp.prettier-vscode
  vscode_remove figma.figma-vscode-extension
  vscode_remove formulahendry.auto-close-tag
  vscode_remove formulahendry.auto-rename-tag
  vscode_remove github.copilot-chat
  vscode_remove github.vscode-pull-request-github
  vscode_remove helgardrichard.helium-icon-theme
  vscode_remove iampeterbanjo.elixirlinter
  vscode_remove jakebecker.elixir-ls
  vscode_remove johnpapa.angular2
  vscode_remove kevinrose.vsc-python-indent
  vscode_remove marnix.peacock
  vscode_remove mblode.twig-language
  vscode_remove mblode.twig-language-2
  vscode_remove mechatroner.rainbow-csv
  vscode_remove mgmcdermott.vscode-language-babel
  vscode_remove mikael.angular-beastcode
  vscode_remove mikestead.dotenv
  vscode_remove ms-azuretools.vscode-azureappservice
  vscode_remove ms-azuretools.vscode-azureresourcegroups
  vscode_remove ms-azuretools.vscode-bicep
  vscode_remove ms-azuretools.vscode-containers
  vscode_remove ms-azuretools.vscode-docker
  vscode_remove ms-dotnettools.csdevkit
  vscode_remove ms-dotnettools.csharp
  vscode_remove ms-dotnettools.vscode-dotnet-runtime
  vscode_remove ms-kubernetes-tools.vscode-kubernetes-tools
  vscode_remove ms-ossdata.vscode-pgsql
  vscode_remove ms-python.black-formatter
  vscode_remove ms-python.debugpy
  vscode_remove ms-python.isort
  vscode_remove ms-python.python
  vscode_remove ms-python.vscode-pylance
  vscode_remove ms-python.vscode-python-envs
  vscode_remove ms-vscode-remote.remote-containers
  vscode_remove ms-vscode.azurecli
  vscode_remove ms-vscode.powershell
  vscode_remove ms-vsliveshare.vsliveshare
  vscode_remove mtxr.sqltools
  vscode_remove naumovs.color-highlight
  vscode_remove nicolasvuillamy.vscode-groovy-lint
  vscode_remove oderwat.indent-rainbow
  vscode_remove orta.vscode-jest
  vscode_remove pkief.material-icon-theme
  vscode_remove redhat.java
  vscode_remove redhat.vscode-yaml
  vscode_remove ritwickdey.liveserver
  vscode_remove rvest.vs-code-prettier-eslint
  vscode_remove sdras.night-owl
  vscode_remove shopify.ruby-lsp
  vscode_remove streetsidesoftware.code-spell-checker
  vscode_remove styled-components.vscode-styled-components
  vscode_remove vincaslt.highlight-matching-tag
  vscode_remove vscjava.vscode-gradle
  vscode_remove vscjava.vscode-java-debug
  vscode_remove vscjava.vscode-java-dependency
  vscode_remove vscjava.vscode-java-pack
  vscode_remove vscjava.vscode-java-test
  vscode_remove vscjava.vscode-maven
  vscode_remove vscodevim.vim
  vscode_remove whatwedo.twig
  vscode_remove xabikos.javascriptsnippets
  vscode_remove yoavbls.pretty-ts-errors
  vscode_remove yzane.markdown-pdf
  vscode_remove zhuangtongfa.material-theme
fi

echo -e "\n${BOLD}Done.${RESET}"
