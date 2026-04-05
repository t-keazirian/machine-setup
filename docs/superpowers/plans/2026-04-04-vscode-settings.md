# VSCode Settings Tracking + VSCodeVim Setup Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Track VSCode's `settings.json` in machine-setup, fix two existing bugs, add missing VSCodeVim config for parity with `.ideavimrc`, and wire up the symlink via `bootstrap.sh`.

**Architecture:** Three file changes in the `machine-setup` public repo. A new `vscode-settings.json` file holds the full cleaned-up settings; `bootstrap.sh` gets a backup and symlink entry for it; `README.md` gets a new section documenting the setup. No changes to `setup.sh` — VSCode is installed via Brewfile cask, not setup.sh.

**Tech Stack:** VSCode, VSCodeVim extension, Bash, JSON

---

## Files

| File | Action | Responsibility |
|------|--------|----------------|
| `vscode-settings.json` | Create | Full VSCode settings — bugs fixed, Vim additions, vs-kubernetes stripped |
| `bootstrap.sh` | Modify | Add backup + symlink for vscode-settings.json |
| `README.md` | Modify | New VSCode settings section |

---

### Task 1: Create `vscode-settings.json`

**Files:**
- Create: `/Users/taylorkeazirian/Code/machine-setup/vscode-settings.json`

- [ ] **Step 1: Verify the current settings.json path**

```bash
ls -la "/Users/taylorkeazirian/Library/Application Support/Code/User/settings.json"
```

Expected: file exists (not a symlink yet).

- [ ] **Step 2: Create `vscode-settings.json` with the following exact content**

This is the current `settings.json` with these changes applied:
- `vs-kubernetes` block removed
- `emmet.syntaxProfiles` bug fixed (was incorrectly containing editor settings)
- `prettier.useTabs` changed from `true` to `false` (user prefers spaces; aligns with `editor.insertSpaces: true`)
- Added: `vim.surround`, `vim.ignorecase`, `vim.smartcase`, `vim.scrolloff`
- Added: `<C-h/j/k/l>` window navigation keymaps to `vim.normalModeKeyBindingsNonRecursive`

```json
{
	"workbench.colorTheme": "One Dark Pro Flat",
	"workbench.iconTheme": "helium-icon-theme",
	"git.autofetch": true,
	"git.confirmSync": false,
	"githubPullRequests.pullBranch": "never",
	"explorer.confirmDragAndDrop": false,
	"emmet.triggerExpansionOnTab": true,
	"emmet.showSuggestionsAsSnippets": true,
	"emmet.syntaxProfiles": {},
	"emmet.includeLanguages": {
		"phoenix-heex": "html"
	},
	"editor.quickSuggestions": {
		"comments": "on",
		"strings": "on",
		"other": "on"
	},
	"editor.fontFamily": "'Dank Mono', Menlo, Monaco, 'Courier New', monospace",
	"editor.suggest.localityBonus": true,
	"editor.cursorBlinking": "solid",
	"editor.detectIndentation": true,
	"editor.accessibilitySupport": "off",
	"editor.wordWrap": "on",
	"editor.tabSize": 2,
	"editor.insertSpaces": true,
	"editor.fontSize": 16,
	"editor.bracketPairColorization.enabled": true,
	"editor.guides.bracketPairs": true,
	"editor.guides.bracketPairsHorizontal": true,
	"editor.guides.highlightActiveBracketPair": true,
	"editor.bracketPairColorization.independentColorPoolPerBracketType": true,
	"editor.formatOnSave": true,
	"editor.tabCompletion": "on",
	"editor.formatOnPaste": true,
	"editor.formatOnSaveMode": "file",
	"editor.renderWhitespace": "all",
	"editor.defaultFormatter": "esbenp.prettier-vscode",
	"prettier.useTabs": false,
	"prettier.arrowParens": "avoid",
	"prettier.singleQuote": false,
	"prettier.jsxSingleQuote": true,
	"[typescript]": {
		"editor.defaultFormatter": "esbenp.prettier-vscode"
	},
	"[typescriptreact]": {
		"editor.defaultFormatter": "esbenp.prettier-vscode"
	},
	"[javascript]": {
		"editor.defaultFormatter": "esbenp.prettier-vscode"
	},
	"[javascriptreact]": {
		"editor.defaultFormatter": "esbenp.prettier-vscode"
	},
	"[elixir]": {
		"editor.defaultFormatter": "JakeBecker.elixir-ls"
	},
	"[csharp]": {
		"editor.defaultFormatter": "ms-dotnettools.csharp"
	},
	"[sql]": {
		"editor.defaultFormatter": "adpyke.vscode-sql-formatter"
	},
	"[yaml]": {
		"editor.defaultFormatter": "redhat.vscode-yaml"
	},
	"[python]": {
		"editor.defaultFormatter": "ms-python.black-formatter",
		"editor.codeLens": false,
		"editor.formatOnPaste": true,
		"editor.formatOnSave": true,
		"diffEditor.ignoreTrimWhitespace": false,
		"editor.renderWhitespace": "all",
		"files.trimTrailingWhitespace": true,
		"editor.formatOnType": true
	},
	"liveServer.settings.donotShowInfoMsg": true,
	"liveServer.settings.CustomBrowser": "chrome",
	"liveServer.settings.donotVerifyTags": true,
	"vim.easymotion": true,
	"vim.inccommand": "replace",
	"vim.incsearch": true,
	"vim.hlsearch": true,
	"vim.useSystemClipboard": true,
	"vim.highlightedyank.enable": true,
	"vim.searchHighlightColor": "#fff",
	"vim.searchMatchColor": "#7A5980",
	"vim.highlightedyank.duration": 1000,
	"vim.useCtrlKeys": true,
	"vim.surround": true,
	"vim.ignorecase": true,
	"vim.smartcase": true,
	"vim.scrolloff": 4,
	"vim.normalModeKeyBindingsNonRecursive": [
		{
			"before": ["u"],
			"after": [],
			"commands": [{ "command": "undo" }]
		},
		{
			"before": ["<C-r>"],
			"after": [],
			"commands": [{ "command": "redo" }]
		},
		{
			"before": ["<C-h>"],
			"commands": [{ "command": "workbench.action.focusLeftGroup" }]
		},
		{
			"before": ["<C-j>"],
			"commands": [{ "command": "workbench.action.focusDownGroup" }]
		},
		{
			"before": ["<C-k>"],
			"commands": [{ "command": "workbench.action.focusUpGroup" }]
		},
		{
			"before": ["<C-l>"],
			"commands": [{ "command": "workbench.action.focusRightGroup" }]
		}
	],
	"tailwindCSS.includeLanguages": {
		"elixir": "html",
		"phoenix-heex": "html"
	},
	"cSpell.ignoreWords": [
		"LWFSS",
		"Parens",
		"buttoncta",
		"dotnettools",
		"esbenp",
		"experimentllc",
		"heex"
	],
	"cSpell.userWords": [
		"ALTM",
		"autogen",
		"blogful",
		"boir",
		"createdb",
		"crosssell",
		"datasources",
		"DOCUSIGN",
		"dunder",
		"enneagram",
		"Freemium",
		"gbooks",
		"glenview",
		"hipaa",
		"keazirian",
		"keazirian's",
		"keepwith",
		"legalzoom",
		"luxon",
		"mifflin",
		"msrp",
		"Negroni",
		"noreferrer",
		"numberify",
		"postdeploy",
		"postgrator",
		"postgresql",
		"predeploy",
		"psql",
		"Rishabh",
		"somers",
		"tailwindcss",
		"testid",
		"thinkful",
		"upsell",
		"USPTO",
		"uuidv",
		"Wireframe",
		"Xunit"
	],
	"editor.stickyScroll.enabled": true,
	"javascript.updateImportsOnFileMove.enabled": "always",
	"diffEditor.ignoreTrimWhitespace": false,
	"window.commandCenter": true,
	"debug.javascript.autoAttachFilter": "disabled",
	"extensions.experimental.affinity": {
		"vscodevim.vim": 1
	},
	"redhat.telemetry.enabled": true,
	"[groovy]": {
		"editor.defaultFormatter": "NicolasVuillamy.vscode-groovy-lint"
	},
	"cSpell.customDictionaries": {
		"custom-dictionary-user": {
			"name": "custom-dictionary-user",
			"path": "~/.cspell/custom-dictionary-user.txt",
			"addWords": true,
			"scope": "user"
		}
	},
	"files.autoSave": "onFocusChange",
	"editor.linkedEditing": true
}
```

- [ ] **Step 3: Verify the file is valid JSON**

```bash
python3 -c "import json; json.load(open('/Users/taylorkeazirian/Code/machine-setup/vscode-settings.json'))" && echo "valid JSON"
```

Expected: `valid JSON`

- [ ] **Step 4: Verify vs-kubernetes is absent**

```bash
grep -c "vs-kubernetes" /Users/taylorkeazirian/Code/machine-setup/vscode-settings.json
```

Expected: `0`

- [ ] **Step 5: Commit**

```bash
cd /Users/taylorkeazirian/Code/machine-setup
git add vscode-settings.json
git commit -m "feat: add vscode-settings.json with Vim parity and bug fixes"
```

---

### Task 2: Update `bootstrap.sh` to backup and symlink `vscode-settings.json`

**Files:**
- Modify: `/Users/taylorkeazirian/Code/machine-setup/bootstrap.sh`

- [ ] **Step 1: Read the current bootstrap.sh to find the right insertion points**

The backup block currently ends with:
```bash
backup ".ideavimrc"
```

The symlink block currently ends with:
```bash
link "$DOTFILES_DIR/.ideavimrc" "$HOME/.ideavimrc"
```

- [ ] **Step 2: Add the VSCode backup entry**

After `backup ".ideavimrc"`, add:

```bash
backup "Library/Application Support/Code/User/settings.json"
```

The `backup` function prepends `$HOME/` to its argument, so this correctly targets `~/Library/Application Support/Code/User/settings.json`.

- [ ] **Step 3: Add the VSCode symlink entry**

After `link "$DOTFILES_DIR/.ideavimrc" "$HOME/.ideavimrc"`, add:

```bash
link "$DOTFILES_DIR/vscode-settings.json" "$HOME/Library/Application Support/Code/User/settings.json"
```

- [ ] **Step 4: Verify syntax**

```bash
bash -n /Users/taylorkeazirian/Code/machine-setup/bootstrap.sh
```

Expected: no output.

- [ ] **Step 5: Run bootstrap to create the live symlink**

```bash
bash /Users/taylorkeazirian/Code/machine-setup/bootstrap.sh
```

Expected: output includes a line linking `vscode-settings.json` to the VSCode settings path.

- [ ] **Step 6: Verify the symlink**

```bash
ls -la "/Users/taylorkeazirian/Library/Application Support/Code/User/settings.json"
```

Expected: symlink pointing to `.../machine-setup/vscode-settings.json`

- [ ] **Step 7: Verify VSCode settings still load (open VSCode and check theme/font)**

Open VSCode. Confirm:
- Theme is still "One Dark Pro Flat"
- Font is still Dank Mono
- No error notifications about invalid settings

- [ ] **Step 8: Commit**

```bash
cd /Users/taylorkeazirian/Code/machine-setup
git add bootstrap.sh
git commit -m "chore: symlink vscode-settings.json in bootstrap"
```

---

### Task 3: Update `README.md` with VSCode settings section

**Files:**
- Modify: `/Users/taylorkeazirian/Code/machine-setup/README.md`

- [ ] **Step 1: Add `vscode-settings.json` to the "What's in here" list**

After the `.ideavimrc` entry, add:

```markdown
- `vscode-settings.json` (symlinked to `~/Library/Application Support/Code/User/settings.json`) — full VSCode settings including VSCodeVim config; tracked so a new machine gets your complete editor environment automatically
```

- [ ] **Step 2: Add `~/Library/.../settings.json` to the "How it works" symlinks list**

After the `~/.ideavimrc` entry, add:

```markdown
- `~/Library/Application Support/Code/User/settings.json` points to `~/Code/machine-setup/vscode-settings.json`
```

- [ ] **Step 3: Add VSCode backup entry to the "What bootstrap.sh does" backup list**

After the `.ideavimrc` backup entry, add:

```markdown
  - `~/Library/Application Support/Code/User/settings.json` → `~/Library/Application Support/Code/User/settings.json.pre-bootstrap`
```

- [ ] **Step 4: Add VSCode entry to the Rollback section**

In the `rm` command, add `"/Users/taylorkeazirian/Library/Application Support/Code/User/settings.json"` — but since README is machine-agnostic, write it as:

```bash
rm "$HOME/Library/Application Support/Code/User/settings.json"
```

And in the restore block add:

```bash
mv "$HOME/Library/Application Support/Code/User/settings.json.pre-bootstrap" \
   "$HOME/Library/Application Support/Code/User/settings.json"
```

- [ ] **Step 5: Add the VSCode settings section after the IdeaVim section**

Find the IdeaVim section (starting with `**IdeaVim (WebStorm Vim emulation)**`) and add this after it:

```markdown
**VSCode settings** — this repo includes `vscode-settings.json` (symlinked to `~/Library/Application Support/Code/User/settings.json`) which tracks your full VSCode environment: theme, font, formatter config, Emmet, spell check words, and VSCodeVim settings. On a new machine, running `bootstrap.sh` gives you your complete VSCode setup automatically — no manual reconfiguration needed.

The file tracks everything except the `vs-kubernetes` block, which contains machine-specific tool paths auto-generated by the VS Kubernetes extension. Those paths will be regenerated by the extension on first launch. When that happens, they'll appear as a git diff in `vscode-settings.json` — do not commit those diffs.

VSCodeVim is already installed via the Brewfile (the `vscodevim.vim` cask entry). The settings file enables surround (`vim.surround`), case-insensitive smart search (`vim.ignorecase` + `vim.smartcase`), scroll context (`vim.scrolloff`), highlighted yank, EasyMotion, and `<C-h/j/k/l>` window navigation mapped to VSCode's split focus commands. Commentary (`gc`/`gcc`) is built into VSCodeVim and active by default — no explicit setting required.

If you change VSCode settings via the UI on your current machine, those changes write directly through the symlink into the tracked file. Run `git diff vscode-settings.json` to see what changed before deciding whether to commit.
```

- [ ] **Step 6: Verify the README renders correctly**

```bash
grep -c "vscode-settings" /Users/taylorkeazirian/Code/machine-setup/README.md
```

Expected: at least 4 occurrences (what's in here, how it works, bootstrap section, new section).

- [ ] **Step 7: Commit**

```bash
cd /Users/taylorkeazirian/Code/machine-setup
git add README.md
git commit -m "docs: add VSCode settings tracking section to README"
```

---

### Task 4: Push and update PR

**Files:** none

- [ ] **Step 1: Push the branch**

```bash
cd /Users/taylorkeazirian/Code/machine-setup
git push
```

- [ ] **Step 2: Update the PR description**

The open PR (t-keazirian/machine-setup#34) covers the vim-plug migration. Add a note that the VSCode settings work is also included:

```bash
gh pr edit 34 --body "$(cat <<'EOF'
## Summary

- Migrated Vim plugin manager from Vundle to vim-plug (parallel installs, auto-install on first launch, no manual \`:PluginInstall\` step)
- Pruned plugin list: dropped 5 abandoned/redundant plugins, corrected 3 moved repo paths
- Added \`.ideavimrc\` for WebStorm's IdeaVim plugin with moderate parity to \`.vimrc\`
- Added \`vscode-settings.json\` tracking full VSCode environment: theme, formatters, VSCodeVim config; symlinked via bootstrap
- Fixed two bugs in existing VSCode settings: misplaced editor settings inside \`emmet.syntaxProfiles\`, and \`prettier.useTabs\`/\`editor.insertSpaces\` conflict (now consistently spaces)
- Added missing VSCodeVim settings: surround, ignorecase/smartcase, scrolloff, \`<C-h/j/k/l>\` window navigation
- Updated \`setup.sh\` to install vim-plug via curl instead of cloning Vundle
- Updated \`bootstrap.sh\` to symlink \`.ideavimrc\` and \`vscode-settings.json\`

## Test Plan

- [ ] \`bash -n setup.sh\` — no output
- [ ] \`bash -n bootstrap.sh\` — no output
- [ ] Open Vim — no errors, \`:PlugStatus\` shows all 17 plugins installed
- [ ] Open VSCode — theme/font intact, no error notifications
- [ ] In VSCode: \`S"\` surrounds in visual mode, \`<C-h/l>\` navigates splits, \`gc\` toggles comments
- [ ] In WebStorm with IdeaVim: \`S"\` surrounds, \`<C-h/l>\` navigates splits

🤖 Generated with [Claude Code](https://claude.com/claude-code)
EOF
)"
```
