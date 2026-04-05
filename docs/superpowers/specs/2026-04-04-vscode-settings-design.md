# VSCode Settings Tracking + VSCodeVim Setup

**Date:** 2026-04-04
**Repo:** machine-setup (public)

---

## Goal

Track `~/Library/Application Support/Code/User/settings.json` in `machine-setup`, clean up existing settings, add missing VSCodeVim config for parity with `.ideavimrc`, and wire up the symlink via `bootstrap.sh`.

---

## Section 1 — File Tracking and Symlink

**File in repo:** `machine-setup/vscode-settings.json`
Using a distinct name (not `settings.json`) to make the file's purpose clear in the repo.

**Symlink target:** `~/Library/Application Support/Code/User/settings.json`

**`bootstrap.sh` changes:**
- Add `backup "Library/Application Support/Code/User/settings.json"` — the `backup` function prepends `$HOME/`, so this correctly targets the existing VSCode settings file before overwriting it with the symlink
- Add `link "$DOTFILES_DIR/vscode-settings.json" "$HOME/Library/Application Support/Code/User/settings.json"`

Note: the destination path contains spaces — the `link` function must quote the argument correctly, which `ln -sf "$src" "$dest"` handles as long as the variable is quoted.

**`setup.sh` changes:** None — VSCode is installed via the Brewfile cask, not setup.sh.

**`vs-kubernetes` block:** Stripped. The extension regenerates these paths on first run per machine. Do not commit those diffs when they appear.

**README:** New section added explaining VSCode settings tracking and what the symlink gives you on a new machine — mirrors the IdeaVim section in style and verbosity.

---

## Section 2 — VSCodeVim Additions

These settings are missing relative to `.ideavimrc` and will be added:

```json
"vim.surround": true,
"vim.ignorecase": true,
"vim.smartcase": true,
"vim.scrolloff": 4,
```

Window navigation keymaps added to `vim.normalModeKeyBindingsNonRecursive` (alongside existing undo/redo entries):

```json
{ "before": ["<C-h>"], "commands": [{ "command": "workbench.action.focusLeftGroup" }] },
{ "before": ["<C-j>"], "commands": [{ "command": "workbench.action.focusDownGroup" }] },
{ "before": ["<C-k>"], "commands": [{ "command": "workbench.action.focusUpGroup" }] },
{ "before": ["<C-l>"], "commands": [{ "command": "workbench.action.focusRightGroup" }] }
```

No test runner keymaps — not used in VSCode.

---

## Section 3 — General Settings Cleanup

**Bug 1 — `emmet.syntaxProfiles` misconfiguration:**

Current (broken):
```json
"emmet.syntaxProfiles": {
  "editor.quickSuggestions": true,
  "editor.tabCompletion": true
}
```

`editor.quickSuggestions` and `editor.tabCompletion` are top-level editor settings, not Emmet syntax profile keys. They are already defined correctly at the top level of the file. The `emmet.syntaxProfiles` block should only map language IDs to syntax types. Fix:

```json
"emmet.syntaxProfiles": {}
```

(The `emmet.includeLanguages` block for `phoenix-heex` is separate and correct — leave it as-is.)

**Bug 2 — `prettier.useTabs` / `editor.insertSpaces` conflict:**

Current:
```json
"prettier.useTabs": true,
"editor.insertSpaces": true,
```

These conflict. User prefers spaces. Fix:
```json
"prettier.useTabs": false,
"editor.insertSpaces": true,
```

---

## Files Changed

| File | Repo | Change |
|------|------|--------|
| `vscode-settings.json` | machine-setup | New file — current settings.json minus vs-kubernetes, with fixes and Vim additions |
| `bootstrap.sh` | machine-setup | Add backup + symlink for vscode-settings.json |
| `README.md` | machine-setup | New VSCode settings section |
