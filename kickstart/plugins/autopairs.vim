" kickstart/plugins/autopairs.vim
"
" The nvim-autopairs equivalent: auto-close brackets/quotes as you type.
" Enable by uncommenting the `execute 'source' ...` line for this file in
" vimrc (SECTION 15).
"
" jiangmiao/auto-pairs is the original and most widely used implementation,
" but it's been unmaintained for years; LunarWatcher/auto-pairs is an
" actively maintained fork of the same plugin with the same behavior and
" config surface, so that's the one used here.
Plug 'LunarWatcher/auto-pairs'

" Key that toggles auto-pairing on/off for the current buffer (this is the
" plugin's default; spelled out here so it's discoverable). Handy when
" pasting code that already has its closing brackets.
let g:AutoPairsShortcutToggle = '<M-p>'
