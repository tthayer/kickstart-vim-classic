" Small helper functions referenced from vimrc that don't fit cleanly as
" inline mapping RHSes. Autoload so they're only parsed on first use.

" Toggle LSP inlay hints.
"
" VERIFIED against plugged/vim-lsp/autoload/lsp/internal/inlay_hints.vim:
" vim-lsp has no public `lsp#ui#vim#inlay_hint#toggle()`-style toggle
" function. What it actually exposes are two internal (leading-underscore)
" functions, `lsp#internal#inlay_hints#_enable()` and `..._disable()`,
" which respectively subscribe/unsubscribe the CursorMoved/CursorHold
" pipeline that requests and renders hints. `_enable()` itself early-returns
" unless `g:lsp_inlay_hints_enabled` is truthy (see autoload/lsp.vim, where
" it's called once during `lsp#enable()`), so a real toggle needs both:
" flip the flag, then call the matching (un)subscribe function.
function! kickstart#toggle_inlay_hints() abort
  let g:lsp_inlay_hints_enabled = !get(g:, 'lsp_inlay_hints_enabled', 0)
  if g:lsp_inlay_hints_enabled
    call lsp#internal#inlay_hints#_enable()
  else
    call lsp#internal#inlay_hints#_disable()
  endif
  echo '[T]oggle Inlay [H]ints: ' . (g:lsp_inlay_hints_enabled ? 'enabled' : 'disabled')
endfunction
