" kickstart/plugins/indent_line.vim
"
" The indent-blankline.nvim equivalent: draws a vertical guide at each
" indent level. Enable by uncommenting the `execute 'source' ...` line for
" this file in vimrc (SECTION 15).

Plug 'Yggdroot/indentLine'

let g:indentLine_char = '┊'

" Don't draw guides in help buffers or terminal windows -- both are noisy
" without adding value there.
let g:indentLine_fileTypeExclude = ['help', 'terminal']
let g:indentLine_bufTypeExclude = ['help', 'terminal']
