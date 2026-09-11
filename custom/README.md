# custom/

Your changes go here, not in `vimrc`, so pulling upstream updates never
conflicts with your configuration.

## custom/plugins/*.vim -- declare plugins

Every `*.vim` file directly in `custom/plugins/` is sourced from inside
vimrc's `plug#begin()`/`plug#end()` block, in sorted filename order. Keep one
plugin per file. A file here may contain `Plug` lines, `let g:...` settings,
mappings, and autocmds; anything that needs to *call a function from the
plugin itself* must be deferred to an `autocmd VimEnter *`, because
`plug#end()` has not run yet while these files are being sourced.

```vim
" custom/plugins/fugitive.vim
Plug 'tpope/vim-fugitive'
nnoremap <leader>gs :Git<CR>
```

## custom/config/*.vim -- override defaults

Every `*.vim` file directly in `custom/config/` is sourced at the very end
of `vimrc`, after all plugins are loaded and the colorscheme is applied.
Anything goes here, with no ordering caveats:

```vim
" custom/config/local.vim
set relativenumber
colorscheme desert
let g:ale_fix_on_save = 0
nnoremap <leader>w :write<CR>
```

## ~/.vimrc.local -- per-machine, outside the repo

Sourced after `custom/config/` if it exists. Use it for things you never
want committed (machine-specific paths, work-only servers, etc.).

## Examples

`custom/plugins/example.vim.disabled` and `custom/config/example.vim.disabled`
are fuller examples of each hook. Rename one to `*.vim` to try it; the
`.disabled` suffix is exactly what keeps them from being sourced by default.
