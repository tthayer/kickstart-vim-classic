" ============================================================================
" ==================== READ THIS BEFORE CONTINUING =========================
" ============================================================================
" ========                                    .-----.          ========
" ========         .----------------------.   | === |          ========
" ========         |.-""""""""""""""""""-.|   |-----|          ========
" ========         ||                    ||   | === |          ========
" ========         ||  KICKSTART-VIM     ||   |-----|          ========
" ========         ||  CLASSIC           ||   | === |          ========
" ========         ||                    ||   |-----|          ========
" ========         ||:help vimtutor      ||   | === |          ========
" ========         |'-..................-'|   |____o|          ========
" ========         `"")----------------(""`   ___________      ========
" ========        /::::::::::|  |::::::::::\  \ no mouse \     ========
" ========       /:::========|  |==hjkl==:::\  \ required \    ========
" ========      '""""""""""""'  '""""""""""""'  '""""""""""'   ========
" ========                                                     ========
" ============================================================================
"
" What is this?
"
"   kickstart-vim-classic is *not* a distribution.
"
"   It is a starting point for your own configuration, for vim-classic
"   (https://vim-classic.org) -- a fork of Vim 8.2 versioned "8.3" that adds
"   a handful of newer Vim features but, crucially, has NO Vim9script. Every
"   line below is legacy Vimscript (`function!`, `let`, `:if` / `:endif`,
"   etc). If you came here from kickstart.nvim, this file plays the exact
"   role that init.lua plays there.
"
"   The goal is that you can read every line, top to bottom, understand
"   what it does, and bend it to your needs. Once you've done that, keep
"   tinkering, or break it into pieces of your own.
"
"   If you don't know Vimscript yet, `:help usr_41.txt` is the built-in
"   "write a Vim script" guide, and `:help eval.txt` is the language
"   reference.
"
" Guide:
"
"   The very first thing you should do is run `:help vimtutor` (or, from a
"   shell, `vimtutor`) if you don't already know Vim's normal-mode basics.
"
"   Next, run AND READ `:help`. It is the single best place to go when
"   you're stuck. We provide `<space>sh` to [S]earch the [H]elp docs, which
"   is invaluable when you don't know exactly what you're looking for.
"
"   NOTE: comments like this one are for you, the reader -- they explain
"   *why*, not just *what*. Delete them once you know what you're doing.
"
"   If you hit errors while installing, check `:messages` and `:PlugStatus`.
"
" P.S. You can delete this banner once you're comfortable. It's your config
" now.
" ============================================================================

" ============================================================================
" SECTION 0: BOOTSTRAP
" Locate this repo on disk, wire up runtimepath, load Vim's own sensible
" defaults, then bootstrap the vim-plug plugin manager.
" ============================================================================

" `s:root` is the directory this file lives in. Using <sfile> (rather than
" assuming ~/.vim) means this exact same vimrc works whether it's cloned to
" ~/.vim, symlinked from ~/.vimrc, or sourced from anywhere via
" `vim -u /path/to/vimrc`.
let s:vimrc = resolve(expand('<sfile>:p'))
let s:root = fnamemodify(s:vimrc, ':h')

" Make sure this repo is on the runtimepath (so `plugin/`, `ftplugin/`, etc.
" under s:root are picked up) even when it is NOT ~/.vim. If you clone this
" repo to ~/.vim (the recommended layout), Vim already put it on rtp before
" this file even ran, and this is a harmless no-op.
if stridx(&runtimepath, s:root) == -1
  execute 'set runtimepath^=' . fnameescape(s:root)
  execute 'set runtimepath+=' . fnameescape(s:root . '/after')
endif

" A copy of s:root usable from inside mappings/functions where script-local
" `s:` variables aren't reachable (see the fzf `<leader>sn` mapping below).
let g:kickstart_root = s:root

" [[ Vim's sensible defaults ]]
" $VIMRUNTIME/defaults.vim is Vim's built-in "reasonable defaults" file --
" the same role Neovim's built-in defaults play for kickstart.nvim (Neovim
" ships most of these on by default; Vim needs you to opt in explicitly).
" It turns on things like syntax highlighting, filetype detection/indent,
" 'hlsearch', 'incsearch', 'nocompatible', mouse support, and more.
" `:help defaults.vim` for the full list. We source it, then override the
" handful of settings kickstart cares about below (mirroring the way
" kickstart.nvim's vim.o block overrides a few of Neovim's own defaults).
if filereadable(expand('$VIMRUNTIME/defaults.vim'))
  unlet! skip_defaults_vim
  source $VIMRUNTIME/defaults.vim
endif

" [[ Syntax highlighting & filetype detection ]]
" defaults.vim only turns these on when it thinks the terminal has colors
" (`&t_Co > 2`), so a misdetected $TERM leaves you with no highlighting at
" all. Set them unconditionally: per-language syntax highlighting, filetype
" detection, filetype-specific plugins (ftplugin/) and indent rules.
"   :help :syntax-on   :help :filetype-overview
syntax enable
filetype plugin indent on

" ============================================================================
" SECTION 1: OPTIONS
" ============================================================================

" Set <space> as the leader key. This MUST happen before plug#begin(), or
" any plugin loaded before this point that uses <leader> in its own default
" mappings will bind to the wrong key.
"  :help mapleader
let mapleader = ' '
let maplocalleader = ' '

" Every autocmd this file defines lives in one augroup that is cleared on
" entry, so re-sourcing the vimrc (`:source ~/.vim/vimrc`, or the first-run
" bootstrap below) never stacks up duplicate autocmds.
"  :help augroup
augroup kickstart_init
  autocmd!
augroup END

" Set to 1 if you have a Nerd Font installed and selected in your terminal.
" Controls whether we use fancy glyphs (diagnostic signs, etc.) or plain
" ASCII fallbacks throughout this config.
let g:have_nerd_font = 0

" Make line numbers default.
set number
" You can also add relative line numbers, to help with jumping.
"   Experiment for yourself to see if you like it!
" set relativenumber

" Enable mouse mode, can be useful for resizing splits, etc.
set mouse=a

" Don't show the mode, since it's already in the (lightline) statusline.
set noshowmode

" Sync clipboard between OS and Vim.
"   On macOS, vim-classic has +clipboard but -xterm_clipboard, which in
"   practice means the '*'/'+' registers work via `set clipboard=unnamed`
"   without needing an X11/xterm clipboard provider. On Linux with a real
"   X11 clipboard you'd normally want 'unnamedplus' too; we add both
"   defensively and let `has()` sort out what's actually supported.
"   Remove this block if you want your OS clipboard to remain independent.
"   :help 'clipboard'
if has('clipboard')
  set clipboard^=unnamed
  if has('unnamedplus')
    set clipboard^=unnamedplus
  endif
endif

" Enable break indent (wrapped lines keep the indent of the line they wrap).
set breakindent

" Enable undo/redo changes even after closing and reopening a file, and
" keep swap files out of the way too. Both live under this repo so a
" `git clean` (or the .gitignore entries) can wipe them without hunting
" through ~/.vim by hand.
if !isdirectory(s:root . '/undo')
  call mkdir(s:root . '/undo', 'p')
endif
if !isdirectory(s:root . '/swap')
  call mkdir(s:root . '/swap', 'p')
endif
set undofile
let &undodir = s:root . '/undo'
let &directory = s:root . '/swap//'

" Case-insensitive searching UNLESS \C or one or more capital letters in the
" search term.
set ignorecase
set smartcase

" Keep signcolumn on by default (LSP diagnostics and git signs live here).
set signcolumn=yes

" Decrease update time (affects CursorHold, used by document-highlight below).
set updatetime=250

" Decrease mapped sequence wait time. Displayed by which-key.
set timeoutlen=300

" Configure how new splits should be opened.
set splitright
set splitbelow

" Sets how Vim will display certain whitespace characters in the editor.
"   :help 'list'
"   :help 'listchars'
set list
set listchars=tab:»\ ,trail:·,nbsp:␣

" NOTE: Neovim has 'inccommand' (live substitution preview as you type).
" Vim-classic has no equivalent option -- there is nothing to set here. If
" you want a taste of it, `:help :s` and consider a plugin, but it is out
" of scope for this base config.

" Show which line your cursor is on.
set cursorline

" Minimal number of screen lines to keep above and below the cursor.
set scrolloff=10

" If performing an operation that would fail due to unsaved changes (like
" `:q`), raise a dialog asking whether to save instead of just erroring.
"   :help 'confirm'
set confirm

" -- The following are things Neovim gives you for free out of the box that
" -- Vim needs spelled out explicitly. Kickstart.nvim doesn't set these
" -- because it doesn't have to; we do.
set hidden        " Allow switching buffers without saving first.
set hlsearch      " Highlight search matches (defaults.vim also sets this).
set encoding=utf-8
set shortmess+=c  " Don't show "match 1 of 2" etc. messages during completion.
set completeopt=menuone,noinsert,noselect

" True color support, if the terminal can do it.
"   :help termguicolors
" NOTE: inside tmux you may also need:
"   set t_8f=\<Esc>[38;2;%lu;%lu;%lum
"   set t_8b=\<Esc>[48;2;%lu;%lu;%lum
" so that Vim knows how to *emit* 24-bit color through tmux's escape codes,
" even though it can already *detect* that the terminal supports it.
if has('termguicolors')
  set termguicolors
endif

" ============================================================================
" SECTION 2: KEYMAPS & AUTOCMDS
" ============================================================================

" Clear highlights on search when pressing <Esc> in normal mode.
"   :help hlsearch
nnoremap <Esc> :nohlsearch<CR>

" Diagnostic keymap -- populated once vim-lsp is loaded (see SECTION 6), but
" the mapping itself is declared here alongside the rest of the core keymaps
" the way kickstart.nvim does it.
nnoremap <leader>q :LspDocumentDiagnostics<CR>

" Exit terminal mode in the builtin terminal with a shortcut that's a bit
" easier to discover than the default <C-\><C-n>.
"   :help terminal-window
tnoremap <Esc><Esc> <C-\><C-n>

" TIP: Disable arrow keys in normal mode
" nnoremap <Left> :echo "Use h to move!"<CR>
" nnoremap <Right> :echo "Use l to move!"<CR>
" nnoremap <Up> :echo "Use k to move!"<CR>
" nnoremap <Down> :echo "Use j to move!"<CR>

" Keybinds to make split navigation easier.
"   Use CTRL+<hjkl> to switch between windows.
"   :help wincmd
nnoremap <C-h> <C-w><C-h>
nnoremap <C-l> <C-w><C-l>
nnoremap <C-j> <C-w><C-j>
nnoremap <C-k> <C-w><C-k>

" NOTE: Some terminals have colliding keymaps or can't send distinct
" keycodes for these.
" nnoremap <C-S-h> <C-w>H
" nnoremap <C-S-l> <C-w>L
" nnoremap <C-S-j> <C-w>J
" nnoremap <C-S-k> <C-w>K

" ============================================================================
" SECTION 3: PLUGIN MANAGER (vim-plug)
" ============================================================================
"
" vim-plug is the Mason/lazy.nvim-equivalent plumbing here: a single-file
" plugin manager that clones plugins with git and adds them to
" 'runtimepath'/'packpath'. It has no Lua/Vim9 dependency, which is exactly
" what we need on vim-classic.
"
" Useful commands (the vim-plug analogs of :Lazy):
"   :PlugStatus   -- show what's installed / out of date / missing.
"   :PlugInstall  -- install anything listed below that isn't installed yet.
"   :PlugUpdate   -- update all installed plugins to their latest commit.
"   :PlugClean    -- remove plugins that are installed but no longer listed
"                    below (vim-plug asks for confirmation first).
"   :PlugUpgrade  -- update vim-plug itself.

" Bootstrap: if vim-plug itself isn't present, download it, then arrange for
" a first-run PlugInstall once Vim finishes starting.
let s:plug_path = s:root . '/autoload/plug.vim'
if empty(glob(s:plug_path))
  silent execute '!curl -fLo ' . shellescape(s:plug_path) . ' --create-dirs '
    \ . 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  " (We re-source this exact file by path rather than `$MYVIMRC`, which is
  " unset when Vim is started with `-u`.)
  execute 'autocmd kickstart_init VimEnter * PlugInstall --sync | source' fnameescape(s:vimrc)
endif

call plug#begin(s:root . '/plugged')

" ---- core plugins are declared throughout SECTION 4 onward; this call is
" ---- closed, and the optional-module / custom-plugin loader placed, near
" ---- the end of this file (still inside the plug#begin/plug#end block: a
" ---- .vim file sourced in between may itself contain `Plug` lines).

" Yank highlight -- vim-classic fires the same TextYankPost autocmd event
" Neovim does (`:help TextYankPost`), so a plugin can hook it exactly the
" way kickstart.nvim's `vim.hl.on_yank()` autocmd does; vim-highlightedyank
" is that plugin, and it wires the autocmd itself once loaded.
Plug 'machakann/vim-highlightedyank'
let g:highlightedyank_highlight_duration = 150

" ============================================================================
" SECTION 4: GUESS-INDENT EQUIVALENT (vim-sleuth)
" ============================================================================
" Detects and sets 'shiftwidth'/'expandtab' per-buffer by sniffing the
" existing indentation of the file you opened. This is the direct analog of
" guess-indent.nvim / mini.nvim's `require('mini.indent')`-adjacent guessing.
Plug 'tpope/vim-sleuth'

" ============================================================================
" SECTION 5: GIT SIGNS (vim-gitgutter)
" ============================================================================
" Shows a +/~/_ gutter for added/changed/removed lines against the git
" index, and provides hunk-level stage/undo/preview -- the gitsigns.nvim
" equivalent.
Plug 'airblade/vim-gitgutter'

" We set our own keymaps below (mirroring gitsigns' on_attach), so tell
" gitgutter not to install its own conflicting defaults.
let g:gitgutter_map_keys = 0
let g:gitgutter_sign_added = '+'
let g:gitgutter_sign_modified = '~'
let g:gitgutter_sign_removed = '_'
let g:gitgutter_sign_removed_first_line = '‾'
let g:gitgutter_sign_modified_removed = '~'

" Navigation -- gitgutter's own next/prev-hunk defaults.
nmap ]c <Plug>(GitGutterNextHunk)
nmap [c <Plug>(GitGutterPrevHunk)

" Hunk actions -- the gitsigns.nvim `<leader>h*` equivalents.
nmap <leader>hs <Plug>(GitGutterStageHunk)
nmap <leader>hu <Plug>(GitGutterUndoHunk)
nmap <leader>hp <Plug>(GitGutterPreviewHunk)

" ============================================================================
" SECTION 6: WHICH-KEY (vim-which-key)
" ============================================================================
" Shows a popup of pending keybinds as you type a prefix -- the
" which-key.nvim equivalent. `timeoutlen` above controls how long Vim waits
" before it decides you've stopped typing a mapping and (via the autocmd
" below) which-key pops up its menu.
Plug 'liuchengxu/vim-which-key'

" Group names + per-key descriptions shown in the popup. The descriptions
" mirror kickstart.nvim's `desc` strings; the mappings themselves are
" defined in the sections that follow.
let g:which_key_map = {}
let g:which_key_map.s = {
  \ 'name': '+[S]earch',
  \ 'h': '[S]earch [H]elp',
  \ 'k': '[S]earch [K]eymaps',
  \ 'f': '[S]earch [F]iles',
  \ 's': '[S]earch [S]elect (commands)',
  \ 'w': '[S]earch current [W]ord',
  \ 'g': '[S]earch by [G]rep',
  \ 'd': '[S]earch [D]iagnostics',
  \ 'r': '[S]earch [R]esume (command history)',
  \ '.': '[S]earch Recent Files ("." for repeat)',
  \ 'n': '[S]earch co[N]fig files',
  \ 't': '[S]earch [T]odos',
  \ '/': '[S]earch [/] in Open Files',
  \ }
let g:which_key_map.t = {
  \ 'name': '+[T]oggle',
  \ 'h': '[T]oggle Inlay [H]ints',
  \ }
let g:which_key_map.h = {
  \ 'name': '+Git [H]unk',
  \ 's': '[S]tage hunk',
  \ 'u': '[U]ndo hunk',
  \ 'p': '[P]review hunk',
  \ }
let g:which_key_map['/'] = '[/] Fuzzily search in current buffer'
let g:which_key_map[' '] = '[ ] Find existing buffers'
let g:which_key_map.q = 'Open diagnostic [Q]uickfix list'
let g:which_key_map.f = '[F]ormat buffer'

" Use a floating popup window when vim-classic has +popupwin (it does);
" otherwise vim-which-key falls back to a regular split.
if has('popupwin')
  let g:which_key_use_floating_win = 1
endif

nnoremap <silent> <leader> :<c-u>WhichKey '<Space>'<CR>
vnoremap <silent> <leader> :<c-u>WhichKeyVisual '<Space>'<CR>

autocmd kickstart_init VimEnter * call which_key#register('<Space>', 'g:which_key_map')

" ============================================================================
" SECTION 7: TELESCOPE EQUIVALENT (fzf + fzf.vim)
" ============================================================================
" fzf.vim is the closest thing vim-classic has to telescope.nvim: a fuzzy
" finder over files, buffers, help tags, grep results, command history, etc.
" `{ 'do': { -> fzf#install() } }` tells vim-plug to build/update the fzf
" binary itself after cloning/updating the fzf repo (a no-op if you already
" have fzf installed via your package manager; it keeps the config portable
" to a machine without a system fzf).
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

" Prefer a centered popup layout (needs +popupwin, which vim-classic has);
" fall back to a bottom split otherwise.
if has('popupwin')
  let g:fzf_layout = { 'window': { 'width': 0.9, 'height': 0.8 } }
else
  let g:fzf_layout = { 'down': '40%' }
endif

" `:Rg` (used below) shells out to ripgrep -- install it if you haven't:
"   brew install ripgrep
nnoremap <leader>sh :Helptags<CR>
nnoremap <leader>sk :Maps<CR>
nnoremap <leader>sf :Files<CR>
nnoremap <leader>ss :Commands<CR>
nnoremap <leader>sw :Rg <C-r><C-w><CR>
nnoremap <leader>sg :Rg<CR>
" fzf.vim has no diagnostics source of its own; this reuses vim-lsp's
" quickfix-list command (see SECTION 9) so the mapping still means
" "[S]earch [D]iagnostics".
nnoremap <leader>sd :LspDocumentDiagnostics<CR>
" fzf.vim's :History: is the closest thing to Telescope's "resume last
" picker" -- it's actually "command-line history", not "resume", but it's
" the nearest fzf.vim equivalent and worth knowing about.
nnoremap <leader>sr :History:<CR>
nnoremap <leader>s. :History<CR>
nnoremap <leader><leader> :Buffers<CR>
nnoremap <leader>/ :BLines<CR>
nnoremap <leader>s/ :Lines<CR>
" `s:` script-local variables aren't visible inside a `nnoremap` RHS, so we
" use the g:kickstart_root copy set in SECTION 0 instead.
nnoremap <leader>sn :execute 'Files' g:kickstart_root<CR>

" ============================================================================
" SECTION 8: LSP (vim-lsp + vim-lsp-settings)
" ============================================================================
" Brief aside: **What is LSP?**
"
" LSP stands for Language Server Protocol. It's a protocol that lets editors
" and language tooling talk to each other in a standardized way.
"
" You have a "server" -- a standalone process built to understand one
" language (`gopls` for Go, `lua-language-server` for Lua, `rust-analyzer`
" for Rust, etc.) -- and a "client", which here is vim-lsp running inside
" vim-classic. LSP gives you:
"   - Go to definition / declaration / type definition
"   - Find references
"   - Autocompletion (via asyncomplete-lsp, SECTION 9)
"   - Symbol search
"   - Diagnostics (errors/warnings inline and in the quickfix list)
"   - Rename, code actions, hover docs, and more
"
" Language servers are external tools, installed separately from the
" editor. vim-lsp-settings is the Mason.nvim equivalent here: it detects
" servers already on $PATH (e.g. a `gopls` you installed with `go install`) and can
" download+install others per-filetype with `:LspInstallServer`.
Plug 'prabirshrestha/vim-lsp'
Plug 'mattn/vim-lsp-settings'

let g:lsp_diagnostics_enabled = 1
let g:lsp_diagnostics_echo_cursor = 1
let g:lsp_diagnostics_virtual_text_enabled = has('textprop')
if has('textprop')
  let g:lsp_diagnostics_virtual_text_align = 'after'
endif
let g:lsp_document_highlight_enabled = 1
let g:lsp_inlay_hints_enabled = 0
let g:lsp_semantic_enabled = 0
let g:lsp_format_sync_timeout = 1000

if g:have_nerd_font
  let g:lsp_diagnostics_signs_error = { 'text': '' }
  let g:lsp_diagnostics_signs_warning = { 'text': '' }
  let g:lsp_diagnostics_signs_information = { 'text': '' }
  let g:lsp_diagnostics_signs_hint = { 'text': '' }
else
  let g:lsp_diagnostics_signs_error = { 'text': 'E' }
  let g:lsp_diagnostics_signs_warning = { 'text': 'W' }
  let g:lsp_diagnostics_signs_information = { 'text': 'I' }
  let g:lsp_diagnostics_signs_hint = { 'text': 'H' }
endif

" Example server settings (uncomment/extend as needed -- see
" `:help g:lsp_settings` and https://github.com/mattn/vim-lsp-settings):
" let g:lsp_settings = {
"   \  'gopls': { 'workspace_config': { 'gopls': { 'directoryFilters': ['-node_modules'] } } },
"   \  'lua-language-server': { 'workspace_config': { 'Lua': { 'diagnostics': { 'globals': ['vim'] } } } },
"   \ }
"
" Commonly wanted servers (install with `:LspInstallServer` while a buffer
" of that filetype is open, or they'll be auto-detected if already on
" $PATH):
"   clangd            -- C / C++
"   gopls             -- Go
"   pyright           -- Python
"   rust-analyzer     -- Rust
"   typescript-language-server (ts_ls) -- TypeScript / JavaScript
"   lua-language-server -- Lua
" `:LspManageServers` lists/updates/uninstalls servers vim-lsp-settings
" manages; `:LspStatus` shows what's currently attached and running.

" This function runs once vim-lsp attaches to a buffer -- the equivalent of
" kickstart.nvim's `LspAttach` autocmd callback. It sets up buffer-local
" completion + all the `gr*`-prefixed goto mappings.
function! s:on_lsp_buffer_enabled() abort
  setlocal omnifunc=lsp#complete
  setlocal signcolumn=yes

  nmap <buffer> grn <plug>(lsp-rename)
  nmap <buffer> gra <plug>(lsp-code-action)
  xmap <buffer> gra <plug>(lsp-code-action)
  nmap <buffer> grr <plug>(lsp-references)
  nmap <buffer> gri <plug>(lsp-implementation)
  nmap <buffer> grd <plug>(lsp-definition)
  nmap <buffer> grD <plug>(lsp-declaration)
  nmap <buffer> grt <plug>(lsp-type-definition)
  nmap <buffer> gO <plug>(lsp-document-symbol)
  nmap <buffer> gW <plug>(lsp-workspace-symbol)
  nmap <buffer> K <plug>(lsp-hover)
  nmap <buffer> [d <plug>(lsp-previous-diagnostic)
  nmap <buffer> ]d <plug>(lsp-next-diagnostic)
  nnoremap <buffer> <leader>th :call kickstart#toggle_inlay_hints()<CR>
endfunction

augroup lsp_install
  autocmd!
  autocmd User lsp_buffer_enabled call s:on_lsp_buffer_enabled()
augroup END

" ============================================================================
" SECTION 9: AUTOCOMPLETION (asyncomplete.vim) & SNIPPETS (vim-vsnip)
" ============================================================================
" asyncomplete.vim + its lsp/buffer sources is the blink.cmp equivalent:
" a popup-menu completion engine fed by pluggable "sources". vim-vsnip is
" the LuaSnip equivalent; vsnip-integ is what makes LSP-supplied snippet
" completions (e.g. a function signature with placeholder args) actually
" expand when accepted, instead of being inserted as inert text.
Plug 'prabirshrestha/asyncomplete.vim'
Plug 'prabirshrestha/asyncomplete-lsp.vim'
Plug 'prabirshrestha/asyncomplete-buffer.vim'
Plug 'hrsh7th/vim-vsnip'
Plug 'hrsh7th/vim-vsnip-integ'

let g:asyncomplete_auto_popup = 1
let g:asyncomplete_auto_completeopt = 0

autocmd kickstart_init VimEnter * call asyncomplete#register_source(
  \ asyncomplete#sources#buffer#get_source_options({
  \   'name': 'buffer',
  \   'whitelist': ['*'],
  \   'completor': function('asyncomplete#sources#buffer#completor'),
  \ }))

" Mappings mirroring blink.cmp's 'default' preset:
"   <C-n>/<C-p>: select next/previous item -- native Vim behavior, no
"     mapping needed while the popup menu is visible.
"   <C-y>: accept ([y]es) the current completion.
inoremap <expr> <C-y> pumvisible() ? asyncomplete#close_popup() : "\<C-y>"
"   <C-space>: force-open the completion menu.
imap <C-space> <Plug>(asyncomplete_force_refresh)
"   <C-e>: close the popup menu without accepting -- native Vim behavior,
"     no mapping needed.
"   <Tab>/<S-Tab>: navigate the popup menu.
inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
"   <C-l>/<C-h>: jump forward/back through vsnip placeholders.
imap <expr> <C-l> vsnip#jumpable(1)  ? '<Plug>(vsnip-jump-next)' : '<C-l>'
smap <expr> <C-l> vsnip#jumpable(1)  ? '<Plug>(vsnip-jump-next)' : '<C-l>'
imap <expr> <C-h> vsnip#jumpable(-1) ? '<Plug>(vsnip-jump-prev)' : '<C-h>'
smap <expr> <C-h> vsnip#jumpable(-1) ? '<Plug>(vsnip-jump-prev)' : '<C-h>'

" ============================================================================
" SECTION 10: FORMATTING (ale)
" ============================================================================
" ALE is doing double duty in the ecosystem (it can lint AND fix), but here
" we use it purely as the conform.nvim equivalent: format-on-save via
" external formatters. Linting is a separate, opt-in concern -- see
" kickstart/plugins/lint.vim.
Plug 'dense-analysis/ale'

" vim-lsp already owns "LSP", so tell ALE not to also start its own LSP
" client (it has one, for linting-only use cases we're not using here).
let g:ale_disable_lsp = 1

" Only run the linters we explicitly list (none, until lint.vim is enabled).
let g:ale_linters_explicit = 1
let g:ale_linters = {}

let g:ale_fixers = {
  \   '*': ['remove_trailing_lines', 'trim_whitespace'],
  \   'lua': ['stylua'],
  \   'go': ['gofmt', 'goimports'],
  \   'python': ['isort', 'black'],
  \   'javascript': ['prettier'],
  \   'typescript': ['prettier'],
  \   'sh': ['shfmt'],
  \ }
let g:ale_fix_on_save = 1

" Mirrors kickstart.nvim's note that C/C++ formatting is opinionated enough
" that autoformat-on-save is often unwelcome without a project-local config.
autocmd kickstart_init FileType c,cpp let b:ale_fix_on_save = 0

nnoremap <leader>f :ALEFix<CR>
" The LSP-side alternative to :ALEFix, when a server's own formatter is
" preferred over an external one:
"   :LspDocumentFormat

" ============================================================================
" SECTION 11: COLORSCHEME (tokyonight-vim)
" ============================================================================
Plug 'ghifarit53/tokyonight-vim'

let g:tokyonight_style = 'night'
let g:tokyonight_enable_italic = 0
let g:tokyonight_disable_italic_comment = 1

" `:colorscheme <Tab>` lets you browse every installed colorscheme. The
" `:colorscheme tokyonight` call itself has to happen AFTER plug#end() (see
" the bottom of this file) -- the plugin's colors/tokyonight.vim isn't on
" 'runtimepath' yet at this point, mid plug#begin()/plug#end() block.

" ============================================================================
" SECTION 12: TODO COMMENTS
" ============================================================================
" There's no todo-comments.nvim equivalent plugin for vim-classic, so this
" is a ~15-line hand-rolled version using matchadd(). A `:syntax match`
" would be the "proper" way, but filetype syntax files often already claim
" the same text (goTodo, vimCommentTitle, ...) and win on precedence;
" matchadd() paints on top of syntax regardless. The trailing colon keeps
" false positives (the word "note" in prose) to a minimum.
"   :help matchadd()
function! s:highlight_todos() abort
  if exists('w:kickstart_todo_matches') | return | endif
  let w:kickstart_todo_matches = [
    \ matchadd('KickstartTodo',  '\<\%(TODO\|PERF\|TEST\):', 10),
    \ matchadd('KickstartFixme', '\<\%(FIXME\|HACK\|WARN\):', 10),
    \ matchadd('KickstartNote',  '\<NOTE:', 10),
    \ ]
endfunction
" matchadd() is per-window, so (re)apply whenever a window is entered.
autocmd kickstart_init VimEnter,WinEnter * call s:highlight_todos()
highlight default link KickstartTodo Todo
highlight default link KickstartFixme WarningMsg
highlight default link KickstartNote Underlined

" NOTE: `|` normally ends a :map command, so inside a mapping it has to be
" written as <Bar>.  :help map_bar
nnoremap <leader>st :Rg \b(TODO<Bar>FIXME<Bar>HACK<Bar>NOTE)\b<CR>

" ============================================================================
" SECTION 13: SMALL PLUGINS COLLECTION (mini.nvim equivalent)
" ============================================================================
" mini.nvim ships a dozen small independent modules from one repo; here we
" reach for the closest single-purpose classics instead.

" mini.ai equivalent -- extra/better text objects (function args, tags,
" etc. beyond Vim's builtin `iw`/`ip`/`i(`).
Plug 'wellle/targets.vim'

" mini.surround equivalent -- add/change/delete surrounding pairs.
"   ys<motion><char> -- [Y]ou-[S]urround (mini: sa, [S]urround [A]dd)
"   ds<char>         -- [D]elete-[S]urround (mini: sd)
"   cs<char><char>   -- [C]hange-[S]urround (mini: sr, [S]urround [R]eplace)
Plug 'tpope/vim-surround'

" `gc{motion}` / `gcc` comment toggling -- Neovim has this built in;
" vim-classic does not, so vim-commentary fills the gap.
Plug 'tpope/vim-commentary'

" mini.statusline equivalent.
Plug 'itchyny/lightline.vim'

function! LightlineLocation() abort
  return line('.') . ':' . col('.')
endfunction

" VERIFIED: ghifarit53/tokyonight-vim ships
" autoload/lightline/colorscheme/tokyonight.vim, so lightline can match the
" editor colorscheme exactly instead of falling back to a bundled one.
let g:lightline = {
  \ 'colorscheme': 'tokyonight',
  \ 'active': {
  \   'left': [ [ 'mode', 'paste' ], [ 'readonly', 'filename', 'modified' ] ],
  \   'right': [ [ 'location' ] ],
  \ },
  \ 'component_function': {
  \   'location': 'LightlineLocation',
  \ },
  \ }

" ============================================================================
" SECTION 14: SYNTAX HIGHLIGHTING (vim-polyglot)
" ============================================================================
" Vim-classic has no Treesitter -- there is no incremental, AST-aware
" parser here, only regex-based `:syntax` files. vim-polyglot is a
" curated bundle of per-language syntax/indent/ftplugin files; it's the
" closest thing to "install a bunch of language support in one line" that
" a regex-highlighting editor can offer.
"
" g:polyglot_disabled MUST be set before the Plug line below: vim-sleuth
" (SECTION 4) already handles indent detection and defaults.vim already
" handles "sensible" options, so we disable polyglot's overlapping bits to
" avoid the two fighting each other.
let g:polyglot_disabled = ['sensible', 'autoindent']
Plug 'sheerun/vim-polyglot'

" ============================================================================
" SECTION 15: OPTIONAL MODULES & CUSTOM PLUGINS
" ============================================================================
" Optional kickstart modules -- uncomment to enable (mirrors kickstart's
" `require 'kickstart.plugins.*'` lines). Each file may itself contain
" `Plug` lines, so they must be sourced from inside this plug#begin block.
" execute 'source' s:root . '/kickstart/plugins/debug.vim'
" execute 'source' s:root . '/kickstart/plugins/indent_line.vim'
" execute 'source' s:root . '/kickstart/plugins/lint.vim'
" execute 'source' s:root . '/kickstart/plugins/autopairs.vim'
" execute 'source' s:root . '/kickstart/plugins/filetree.vim'

" Extension point #1 -- your own PLUGINS (the `lua/custom/plugins/*.lua`
" equivalent). Every `*.vim` file directly inside custom/plugins/ is
" sourced here, in sorted order. A file dropped here may contain `Plug`
" lines, `let g:...` settings, mappings, and autocmds; anything that needs
" to call a *plugin function* (rather than just set a variable it reads
" later) must be deferred to an `autocmd VimEnter *` inside that file,
" since plug#end() hasn't run yet at this point in the load order.
" See custom/README.md for the full contract and an example.
for s:f in sort(glob(s:root . '/custom/plugins/*.vim', 0, 1))
  execute 'source' fnameescape(s:f)
endfor
unlet! s:f

call plug#end()

" ---- everything below this line runs after all plugins are on
" ---- 'runtimepath', i.e. after plug#end().

" Apply the colorscheme configured in SECTION 11, now that
" colors/tokyonight.vim is actually reachable. Wrapped in try/catch so a
" first run (before :PlugInstall has completed) doesn't hard-error.
try
  silent! colorscheme tokyonight
catch
endtry

" Auto-run PlugInstall for any plugin declared above but not yet installed
" on disk -- covers "you pulled a vimrc update that adds a new Plug line"
" without needing to remember to run :PlugInstall by hand.
function! s:auto_install_missing_plugins() abort
  let l:missing = filter(copy(g:plugs), '!isdirectory(v:val.dir)')
  if !empty(l:missing)
    PlugInstall --sync
  endif
endfunction
autocmd kickstart_init VimEnter * call s:auto_install_missing_plugins()

" ============================================================================
" SECTION 16: YOUR OVERRIDES (custom/config)
" ============================================================================
" Extension point #2 -- your own SETTINGS. Everything above is a default;
" this is where you change your mind about any of it without editing this
" file (so pulling upstream updates stays conflict-free). Every `*.vim`
" file directly inside custom/config/ is sourced here, in sorted order,
" LAST -- after all plugins are loaded and the colorscheme is applied. So
" a file here can:
"   - override options:        set relativenumber
"   - pick another colorscheme: colorscheme desert
"   - add or change mappings:   nnoremap <leader>w :write<CR>
"   - configure a plugin:       let g:ale_fix_on_save = 0
"   - call plugin functions directly (no VimEnter deferral needed).
" custom/plugins/*.vim is for declaring plugins; custom/config/*.vim is
" for everything else. See custom/README.md.
for s:f in sort(glob(s:root . '/custom/config/*.vim', 0, 1))
  execute 'source' fnameescape(s:f)
endfor
unlet! s:f

" Last-resort escape hatch for a per-machine file that lives OUTSIDE this
" repo (never committed, never in conflict): ~/.vimrc.local, if it exists.
if filereadable(expand('~/.vimrc.local'))
  source ~/.vimrc.local
endif

" The line beneath this is called a modeline. See `:help modeline`.
" vim: ts=2 sts=2 sw=2 et
