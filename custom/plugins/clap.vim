" custom/plugins/clap.vim -- vim-clap
"
" A fuzzy picker (the fzf.vim role) that ALSO does real Tree-sitter syntax
" highlighting of ordinary buffers. Everything else in this config is plain
" Vimscript; this one is not, and that trade is the whole point of keeping
" it on a personal branch instead of main:
"
"   - Parsing happens in `maple`, a Rust binary vim-clap ships separately.
"     Without it you get no picker and no highlighting.
"   - Highlights are delivered asynchronously over a job/channel and painted
"     with |textprop|s, so they land a beat after the buffer is drawn.
"   - Only the grammars compiled into that binary are supported: bash, c,
"     cpp, dockerfile, go, javascript, json, markdown, python, rust, swift,
"     toml, vim. Everything else keeps Vim's regex highlighting.
"
" vim-clap needs Vim 8.1.2114+; vim-classic is 8.2.0148, so it qualifies.
"
" The `do` hook fetches a prebuilt `maple` for your platform on install and
" on every :PlugUpdate. It runs the download in a terminal window, so it
" only works in an interactive Vim -- if you install headlessly, or it
" reports nothing, fetch the binary by hand with `:Clap install-binary!`
" and check `plugged/vim-clap/bin/maple version` afterwards.
Plug 'liuchengxu/vim-clap', { 'do': ':Clap install-binary!' }

" Required for the Tree-sitter highlighter. This is what installs the
" buffer autocmds (BufEnter, TextChangedI, BufWritePost, ...) that notify
" the maple server about buffer state, and what creates :ClapAction. The
" picker works without it; the highlighting does not.
let g:clap_plugin_experimental = 1

" Render the whole buffer rather than only the visible lines, up to
" vim-clap's 256 KiB default cutoff. Set in the maple config file, not here
" (see PERSONAL.md); noted for discoverability:
"   [plugin.syntax.render-strategy]
"   strategy = "entire-buffer-up-to-limit"

" Match the rest of this config: popup layout, no devicons unless a Nerd
" Font is actually selected.
let g:clap_layout = { 'relative': 'editor', 'width': '70%', 'height': '40%', 'row': '15%', 'col': '15%' }
let g:clap_enable_icon = g:have_nerd_font
