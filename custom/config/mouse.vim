" custom/config/mouse.vim -- let the terminal keep the mouse
"
" vimrc sets `mouse=a`, mirroring kickstart.nvim. The cost is that Vim then
" asks the terminal for button-event tracking (DEC private mode 1002), so
" every click-drag becomes a Vim Visual selection and Ghostty never sees it
" -- no select-to-copy, no middle-click paste, no drag across a tmux pane.
"
" Vim's mouse buys very little here: :vertical resize and <C-w>+/- resize
" splits, and hjkl moves the cursor faster than aiming does. Terminal
" selection is worth more, so hand the mouse back.
"
" This is a per-session default, not a one-way door -- <leader>tm still
" flips it, so you can grab the mouse when you actually want to drag a
" split boundary, then drop it again.
set mouse=

" 'ttymouse' stays on sgr (set in vimrc). It costs nothing while 'mouse' is
" empty, and it means that IF you toggle the mouse on, the modern protocol
" is used -- the old xterm default reports coordinates as raw bytes, which
" breaks past column 223 and makes vim-which-key print stray
" "SPC <M-&> is undefined" errors.
