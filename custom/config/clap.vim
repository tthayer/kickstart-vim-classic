" custom/config/clap.vim -- point the search keys at vim-clap
"
" Sourced last, after vimrc has already mapped <leader>s* to fzf.vim, so
" these simply win. fzf.vim stays installed and its :Files / :Rg / :Buffers
" commands still work if you want to compare the two.

" Same keys, same meanings as vimrc SECTION 7 -- only the provider changes.
nnoremap <leader>sh :Clap help_tags<CR>
nnoremap <leader>sk :Clap maps<CR>
nnoremap <leader>sf :Clap files<CR>
nnoremap <leader>ss :Clap command<CR>
nnoremap <leader>sw :Clap grep ++query=<cword><CR>
nnoremap <leader>sg :Clap grep<CR>
nnoremap <leader>sr :Clap command_history<CR>
nnoremap <leader>s. :Clap recent_files<CR>
nnoremap <leader><leader> :Clap buffers<CR>
nnoremap <leader>/ :Clap blines<CR>
nnoremap <leader>s/ :Clap lines<CR>
execute 'nnoremap <leader>sn :Clap files ++finder=rg\ --files' g:kickstart_root . '<CR>'

" <leader>sd stays on :LspDocumentDiagnostics -- vim-clap has no
" diagnostics provider, and vim-lsp owns diagnostics here.

" Providers vim-clap adds that fzf.vim has no equivalent for.
nnoremap <leader>sp :Clap providers<CR>
nnoremap <leader>sy :Clap yanks<CR>
let g:which_key_map.s.p = '[S]earch [P]roviders (all of vim-clap)'
let g:which_key_map.s.y = '[S]earch [Y]ank history'

" [[ Tree-sitter highlighting ]]
" The syntax plugin starts switched off; `treeSitterHighlight` turns it on
" and the flag sticks, so every buffer opened afterwards is parsed too.
" Guarded three ways because none of this exists until the Rust binary is
" downloaded: the command, the binary itself, and the notify call.
function! s:enable_tree_sitter() abort
  if !exists(':ClapAction') || !filereadable(g:kickstart_root . '/plugged/vim-clap/bin/maple')
    return
  endif
  try
    ClapAction treeSitterHighlight
  catch
    " maple not running yet -- :ClapAction treeSitterHighlight by hand.
  endtry
endfunction
autocmd kickstart_init VimEnter * call timer_start(200, { -> s:enable_tree_sitter() })

" Toggle it off/on to see exactly what Tree-sitter is adding over Vim's
" regex syntax, and inspect the capture under the cursor.
nnoremap <leader>tt :ClapAction toggle<CR>
nnoremap <leader>tp :ClapAction treeSitterPropsUnderCursor<CR>
let g:which_key_map.t.t = '[T]oggle [T]ree-sitter highlighting'
let g:which_key_map.t.p = '[T]ree-sitter: show ca[P]ture under cursor'
