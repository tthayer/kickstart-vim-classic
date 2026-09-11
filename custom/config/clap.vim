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
"
" READ THIS BEFORE TURNING IT ON. Tested against vim-classic 8.3 with
" maple v0.55, and it is only half-working:
"
"   - It highlights a buffer correctly exactly ONCE. Every refresh after
"     that (:w, editing, re-running the action) throws E968 and the
"     highlights go stale. Cause: vim-clap's non-Neovim path calls
"     `prop_remove({'types': [...]})`, and real Vim's prop_remove() has no
"     'types' key -- only singular 'type'/'id'. Verified directly:
"       call prop_remove({'types': ['x']}, 1, 1)
"       -> E968: Need at least one of 'id' or 'type'
"     The first pass survives only because it skips prop_remove entirely.
"   - On Go it is not clearly better than vim-polyglot's regex syntax. It
"     wins on struct fields (regex gives them no group at all), ties on
"     parameters, and LOSES on builtins: regex tags `len` as goBuiltins,
"     Tree-sitter leaves it a plain Identifier. Function definitions and
"     calls both come back as `property`, so it does not even make the
"     distinction that motivates Tree-sitter in the first place.
"   - None of this is documented upstream; the changelog still refers to an
"     action name that no longer exists.
"
" So: OFF by default. Flip this to 1 to experiment, and expect to re-run
" the action by hand after edits.
let g:kickstart_clap_tree_sitter = get(g:, 'kickstart_clap_tree_sitter', 0)

" Actions are namespaced `<plugin-id>.<action>` (types::PLUGIN_ACTION_SEPARATOR
" is '.'), so the bare action name silently does nothing. The syntax plugin
" starts switched off and no config key turns it on -- only this action does.
function! s:enable_tree_sitter() abort
  if !g:kickstart_clap_tree_sitter || !exists(':ClapAction')
    return
  endif
  if !filereadable(g:kickstart_root . '/plugged/vim-clap/bin/maple')
    return
  endif
  try
    ClapAction syntax.treeSitterHighlight
  catch
    " maple not up yet -- run :ClapAction syntax.treeSitterHighlight by hand.
  endtry
endfunction
autocmd kickstart_init VimEnter * call timer_start(500, { -> s:enable_tree_sitter() })

" Re-apply after a write, since incremental refresh is broken (see above).
autocmd kickstart_init BufWritePost * call s:enable_tree_sitter()

" Toggle it off/on to see exactly what Tree-sitter adds over Vim's regex
" syntax, and inspect the capture under the cursor.
nnoremap <leader>tt :ClapAction syntax.toggle<CR>
nnoremap <leader>tp :ClapAction syntax.treeSitterPropsUnderCursor<CR>
let g:which_key_map.t.t = '[T]oggle [T]ree-sitter highlighting'
let g:which_key_map.t.p = '[T]ree-sitter: show ca[P]ture under cursor'
