" kickstart/plugins/debug.vim
"
" The nvim-dap equivalent, using puremourning/vimspector. Enable by
" uncommenting the `execute 'source' ...` line for this file in vimrc
" (SECTION 15).
"
" CAVEAT: vimspector needs +python3. Many vim-classic builds (the Homebrew
" one included) only have a *dynamic* python3 (`python3/dyn`), which
" reports `has('python3')` = 0 until a matching Python is installed -- so
" below we make this file a safe no-op with a warning rather than a Plug
" line that would half-load. To actually use vimspector:
"   1. install a Python 3 that your vim-classic build can dlopen (on
"      Homebrew: `brew install python@3.14`; check `vim --version` for the
"      exact version it was built against)
"   2. confirm `:echo has('python3')` reports 1
"   3. delete the `if !has('python3') | ... | finish | endif` guard below
"
" For Go specifically, `delve` (`brew install delve` / `go install
" github.com/go-delve/delve/cmd/dlv@latest`) is the debugger vimspector
" would drive via its Go gadget -- install it either way, it's also usable
" standalone (`dlv debug`).

if !has('python3')
  echomsg 'kickstart/plugins/debug.vim: vimspector needs +python3, which this '
    \ . 'vim-classic build does not have loaded. Install a Python 3 your '
    \ . 'build can dlopen (see the comments in this file) or use a '
    \ . 'standalone debugger like `dlv` for Go instead.'
  finish
endif

Plug 'puremourning/vimspector'

" Explicit mappings mirroring kickstart.nvim's nvim-dap keys. (vimspector's
" own `g:vimspector_enable_mappings = 'HUMAN'` preset is left off because
" its F-key layout collides with these.)
nnoremap <F5> :call vimspector#Launch()<CR>
nnoremap <F1> :call vimspector#StepInto()<CR>
nnoremap <F2> :call vimspector#StepOver()<CR>
nnoremap <F3> :call vimspector#StepOut()<CR>
nnoremap <leader>b :call vimspector#ToggleBreakpoint()<CR>
nnoremap <leader>B :call vimspector#ToggleBreakpoint({'condition': input('Condition: ')})<CR>
