# personal branch

Personal customizations on top of `main`. `main` stays the teaching config:
plain Vimscript, no compiled dependencies, readable top to bottom. This
branch is where that rule gets broken on purpose.

Nothing here edits `vimrc`. Everything lives in the `custom/` extension
points `main` already provides, so `git rebase main` should stay clean.

## What this branch adds

**vim-clap** (`custom/plugins/clap.vim`, `custom/config/clap.vim`) replaces
fzf.vim as the fuzzy picker and adds real Tree-sitter syntax highlighting
for ordinary buffers. The `<leader>s*` keys keep their meanings and only
change provider. fzf.vim stays installed, so `:Files`, `:Rg`, and
`:Buffers` still work if you want to compare.

Two keys are new, plus two for the highlighter:

| Key | Does |
| --- | --- |
| `<leader>sp` | List every vim-clap provider |
| `<leader>sy` | Yank history |
| `<leader>tt` | Toggle Tree-sitter highlighting |
| `<leader>tp` | Show the Tree-sitter capture under the cursor |

## Why it is not on main

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

Tree-sitter highlighting turns itself on shortly after startup. To do it
manually, or to check whether it is running:

```vim
:ClapAction treeSitterHighlight
```

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
