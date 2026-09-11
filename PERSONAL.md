# personal branch

Personal customizations on top of `main`. `main` stays the teaching config:
plain Vimscript, no compiled dependencies, readable top to bottom. This
branch is where that rule gets broken on purpose.

Nothing here edits `vimrc`. Everything lives in the `custom/` extension
points `main` already provides, so `git rebase main` should stay clean.

## What this branch adds

**vim-clap** (`custom/plugins/clap.vim`, `custom/config/clap.vim`) replaces
fzf.vim as the fuzzy picker. The `<leader>s*` keys keep their meanings and
only change provider. fzf.vim stays installed, so `:Files`, `:Rg`, and
`:Buffers` still work if you want to compare.

vim-clap can also do real Tree-sitter highlighting of ordinary buffers.
That part is **off by default** because testing showed it only half works
on Vim. See below.

Two keys are new, plus two for the highlighter:

| Key | Does |
| --- | --- |
| `<leader>sp` | List every vim-clap provider |
| `<leader>sy` | Yank history |
| `<leader>tt` | Toggle Tree-sitter highlighting |
| `<leader>tp` | Show the Tree-sitter capture under the cursor |

**Mouse off** (`custom/config/mouse.vim`). `main` sets `mouse=a` like
kickstart.nvim, which makes Vim request terminal mouse tracking, so
click-drag becomes a Vim Visual selection and Ghostty never sees it. This
branch hands the mouse back so select-to-copy works. `<leader>tm` still
grabs it when you want to drag a split boundary.

## Why vim-clap is not on main

vim-clap parses buffers in `maple`, a Rust binary it ships separately.
That means a compiled dependency, highlights that arrive asynchronously
over a channel rather than at paint time, and coverage limited to the
grammars built into that binary: bash, c, cpp, dockerfile, go, javascript,
json, markdown, python, rust, swift, toml, vim. Everything else falls back
to Vim's regex syntax.

For a config whose pitch is "read every line," that trade belongs on a
branch.

## Setup

`:PlugInstall` fetches the plugin, and its `do` hook downloads a prebuilt
`maple`. That hook runs in a terminal window, so it only fires in an
interactive Vim. Confirm it landed:

```sh
plugged/vim-clap/bin/maple version
```

If that file is missing, run `:Clap install-binary!` inside Vim.

## Tree-sitter highlighting, and why it is off

Set `g:kickstart_clap_tree_sitter = 1` to try it. Tested against
vim-classic 8.3 with maple v0.55, it has two real problems.

**It highlights each buffer exactly once.** Every refresh afterwards
throws `E968` and the highlights go stale. vim-clap's non-Neovim path
calls `prop_remove({'types': [...]})`, but Vim's `prop_remove()` has no
`types` key, only singular `type` and `id`. Reproduced directly:

```vim
call prop_remove({'types': ['x']}, 1, 1)
" E968: Need at least one of 'id' or 'type'
```

The first pass survives only because it skips `prop_remove` entirely. The
config re-runs the action on `BufWritePost` as a partial workaround.

**On Go it is not clearly better than the regex syntax.** It wins on
struct fields, which vim-polyglot gives no group at all. It ties on
parameters. It loses on builtins: regex tags `len` as `goBuiltins`, while
Tree-sitter leaves it a plain identifier. Function definitions and calls
both come back as `property`, so it does not even draw the distinction
that makes Tree-sitter worth wanting.

To drive it by hand, note that actions are namespaced `<plugin-id>.<action>`.
The bare name silently does nothing:

```vim
:ClapAction syntax.treeSitterHighlight
```

None of this is documented upstream, and the changelog still names an
action that no longer exists.

To render the whole buffer instead of only the visible lines, create
maple's config file and add:

```toml
[plugin.syntax.render-strategy]
strategy = "entire-buffer-up-to-limit"
```

On macOS that file is
`~/Library/Application Support/org.vim.Vim-Clap/config.toml`; on Linux it
is `~/.config/vimclap/config.toml`.

## Keeping up with main

```sh
git checkout personal
git rebase main
```
