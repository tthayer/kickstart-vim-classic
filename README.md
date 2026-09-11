# kickstart-vim-classic

## Introduction

[vim-classic](https://vim-classic.org) is a fork of Vim 8.2.0148 (versioned
"8.3") that backports a handful of newer features -- jobs, channels,
timers, popup windows, text properties, terminal buffers -- onto the
Vim 8 codebase, but deliberately never adopted Vim9script. If you know
Vim, you already know vim-classic; every line in this repo is legacy
Vimscript (`function!`, `let`, `:if`/`:endif`, ...).

[Kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim) is a
single-file, from-scratch Neovim configuration meant to be read, understood,
and grown -- not a pre-packaged "distribution" you install and forget.
kickstart-vim-classic is the same idea, for vim-classic: one heavily
commented `vimrc`, small enough to read top to bottom in one sitting, that
gets you a modern-feeling editing experience (LSP, fuzzy finding, git
signs, completion, formatting) built entirely out of plain Vimscript
plugins. This is a teaching config, not a distribution -- fork it, read it,
change it.

## Installation

### Install vim-classic

macOS:

```sh
brew install vim-classic
```

vim-classic's Homebrew formula conflicts with the `vim` and `macvim`
formulae (they all want to provide the same `vim` binary/symlinks) --
either uninstall those first or invoke vim-classic by its full path,
`$(brew --prefix vim-classic)/bin/vim`. If `vim` doesn't do what you
expect, check `which -a vim` and your shell rc files for an alias (a
`vim=nvim` alias is common).

Linux / Windows: vim-classic doesn't have consistent distro packaging yet.
Build from the source tarball on [vim-classic.org](https://vim-classic.org)
following that site's build instructions; packaging status varies by
platform and may change.

### Install external dependencies

- `git` and `curl` -- required, used by vim-plug to fetch plugins.
- `ripgrep` (`brew install ripgrep`) -- powers the `:Rg` fuzzy-grep
  mappings (`<leader>sg`, `<leader>sw`, `<leader>st`).
- `fzf` -- the `junegunn/fzf` plugin will build it for you on first
  `:PlugInstall` if it's missing, but `brew install fzf` is recommended so
  you get a system-wide `fzf` binary too.
- A [Nerd Font](https://www.nerdfonts.com/) -- optional. Leave
  `g:have_nerd_font = 0` in vimrc unless you've installed and selected one
  in your terminal.
- Language servers -- installed as needed, per-project, via
  `:LspInstallServer` (see "Post installation" below).
- Formatters like `stylua`, `gofmt`/`goimports`, `black`/`isort`,
  `prettier` -- installed as needed for the languages you actually use;
  see the `g:ale_fixers` table in vimrc (SECTION 10).

### Install kickstart-vim-classic

It's recommended you fork this repo so you can track your own changes,
then clone your fork to the path vim-classic reads `vimrc` from:

```sh
git clone https://github.com/<you>/kickstart-vim-classic.git ~/.vim
```

(Or clone the upstream repo directly, if you'd rather not fork yet:
`git clone https://github.com/tthayer/kickstart-vim-classic.git ~/.vim`.)

On Windows, the equivalent path is `%USERPROFILE%\vimfiles`.

Alternatively, clone it anywhere and add one line to your existing
`~/.vimrc`:

```vim
source /path/to/kickstart-vim-classic/vimrc
```

### Post installation

Start vim-classic:

```sh
vim
```

On first run, vim-plug bootstraps itself and installs every plugin listed
in `vimrc` (this can take a minute). Once that finishes, open a file in a
language you use and run `:LspInstallServer` to install (or detect an
already-installed) language server for that filetype.

- `:PlugStatus` -- the `:checkhealth` equivalent for plugins: what's
  installed, what's missing, what's out of date.
- `:LspStatus` -- the `:checkhealth` equivalent for LSP: which servers are
  attached and running for the current buffer.

## Getting started

Read `vimrc` top to bottom -- it's written as a tutorial, with a comment
above nearly every setting explaining *why* it's there and what it does in
Neovim/kickstart.nvim terms if you're coming from there. Then `:help` is
always the right next stop for anything unclear.

## FAQ

**Why vim-classic, and what does "no Vim9script" rule out?**
vim-classic never implemented Vim9script, so any plugin written against it
is off the table -- most notably `yegappan/lsp` and other Vim9-only LSP
clients/completion engines. This config uses `prabirshrestha/vim-lsp`
instead, which predates Vim9script and works fine on any Vim 8+.

**What about coc.nvim?**
It works if you want a Node.js-based LSP client/completion stack instead
of vim-lsp -- but it's not what this config defaults to, to keep the
dependency footprint to git/curl/vim only.

**Why not use ALE for LSP too, instead of vim-lsp?**
ALE can act as an LSP client, but vim-lsp is more feature-complete for
that specific job (code actions, rename, document symbols, etc.), so this
config splits the responsibility: vim-lsp owns LSP, ALE owns
formatting/fixing (and optionally linting, via `kickstart/plugins/lint.vim`).

**Why vim-plug instead of Vim's native `pack/` directories?**
Native packages (`:help packages`) work without any plugin manager, but
you're on your own for cloning/updating/removing them. vim-plug adds
`:PlugInstall`/`:PlugUpdate`/`:PlugClean` and a single declarative list in
one file, at the cost of one small bootstrap script.

**Can I use this with mainline Vim 9 instead of vim-classic?**
Yes -- nothing here relies on a vim-classic-specific patch. Vim9script
plugins still won't be Vim9script here (this config doesn't use any), but
they'd still be usable on real Vim 9 if you added them yourself.

**Can I use this with Neovim?**
No -- use [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim)
itself, this repo mirrors it structurally, not literally.

**How do I add my own plugins or override a default?**
See [Customizing](#customizing) below.

## Customizing

You never have to edit `vimrc` to make this config yours (though you're
welcome to -- it's your fork). Three hooks, in load order:

1. `custom/plugins/*.vim` -- declare plugins. Sourced inside the vim-plug
   block, so `Plug 'owner/repo'` lines work here. One plugin per file.
2. `custom/config/*.vim` -- override anything. Sourced last, after every
   plugin is loaded and the colorscheme is applied, so `set`, `colorscheme`,
   mappings, `let g:...` plugin settings, and direct plugin function calls
   all work here with no ordering caveats.
3. `~/.vimrc.local` -- same as 2, but lives outside the repo for
   per-machine settings you never want committed.

`custom/README.md` has the details and an example of each. Optional
kickstart modules (debugger, file tree, linting, indent guides, autopairs)
live in `kickstart/plugins/` and are enabled by uncommenting one line each
in `vimrc` (SECTION 15).

## License

[MIT](LICENSE).
