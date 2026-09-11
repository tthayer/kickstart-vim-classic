" kickstart/plugins/filetree.vim
"
" The neo-tree.nvim equivalent. Enable by uncommenting the
" `execute 'source' ...` line for this file in vimrc (SECTION 15).
"
" NOTE: vim-classic already ships netrw (`:help netrw`), a zero-plugin file
" explorer -- try `:Explore` / `:Vexplore` / `:Sexplore` before reaching for
" NERDTree if you'd rather not add a dependency.
Plug 'preservim/nerdtree'

let g:NERDTreeShowHidden = 1

" Mirrors kickstart.nvim's neo-tree `\` binding.
nnoremap \ :NERDTreeToggle<CR>
" `q` closes the NERDTree window by default; no mapping needed.
