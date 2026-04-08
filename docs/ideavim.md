# IdeaVim Setup (WebStorm)

This repo includes `.ideavimrc` (symlinked to `~/.ideavimrc`) which configures Vim emulation inside WebStorm. The file does nothing on its own — IdeaVim must be installed first.

## Installation

1. Open WebStorm → `Settings → Plugins`, search for **IdeaVim**, install it, and restart. It's a first-party JetBrains plugin and requires no separate license.

2. After restarting, open a file and confirm Vim normal mode is active (block cursor or `-- NORMAL --` in the status bar). Then run `:set surround?` in the IdeaVim command line. If it returns `surround` (not `nosurround`), the `.ideavimrc` was loaded. If not, go to `Settings → Tools → IdeaVim` and confirm the path points to `~/.ideavimrc`.

## What `.ideavimrc` enables

Three IdeaVim extensions bundled with the plugin (no separate install required):

- **`surround`** — `S"` in visual mode to wrap selections, `cs"'` to change surrounds, `ds"` to delete them. Mirrors `tpope/vim-surround`.
- **`commentary`** — `gcc` to comment a line, `gc` with a motion. Mirrors `tpope/vim-commentary`.
- **`highlightedyank`** — briefly highlights yanked text.

It also mirrors search behavior, editor settings, split behavior, folding, and `<C-h/j/k/l>` window navigation from `.vimrc`. Color settings, cursor shapes, ALE, Lightline, and format-on-save are intentionally absent — WebStorm handles all of that natively.

## Test runner keymaps

`<Leader>tn`, `<Leader>tf`, `<Leader>ts`, and `<Leader>tl` are mapped to WebStorm's built-in test runner actions — approximate equivalents to the `test.vim` keymaps in `.vimrc`:

| Keymap | Action | WebStorm equivalent |
|---|---|---|
| `<Leader>tn` | Run test at cursor | `RunClass` |
| `<Leader>tf` | Run all tests in file | `RunClass` (infers scope) |
| `<Leader>ts` | Run current run configuration | `Run` |
| `<Leader>tl` | Rerun last run | `Rerun` |

Verify any action name with `:actionlist <name>` in the IdeaVim command line.

## What IdeaVim does not support

IdeaVim has no plugin system equivalent to vim-plug. The `set surround`, `set commentary`, and `set highlightedyank` lines activate extensions **bundled with IdeaVim**, not installed from GitHub. Any plugin installed via vim-plug in terminal Vim has no effect in WebStorm. For additional behavior, check the [IdeaVim supported plugins list](https://github.com/JetBrains/ideavim/wiki/IdeaVim-Plugins) — only plugins on that list can be activated via `.ideavimrc`.

To toggle Vim mode without uninstalling: `Tools → IdeaVim` or the Vim logo in the IDE status bar.
