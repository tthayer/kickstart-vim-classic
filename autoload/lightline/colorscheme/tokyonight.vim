" =============================================================================
" autoload/lightline/colorscheme/tokyonight.vim
" =============================================================================
" A lightline (itchyny/lightline.vim) theme built from folke/tokyonight.nvim's
" own lualine theme (lua/lualine/themes/_tokyonight.lua): mode ("a") segments
" are colored bg=<mode color> fg=black, the next ("b") segment is
" bg=fg_gutter fg=<mode color>, and the remaining ("c"/middle) segment is
" fg_sidebar text on bg_statusline -- exactly what lualine does for
" normal/insert/visual/replace/inactive. Modeled structurally after
" plugged/lightline.vim/autoload/lightline/colorscheme/one.vim (the
" `lightline#colorscheme#flatten(s:p)` shape lightline itself expects).
"
" `black` and `bg_statusline` are the two colors that differ between the
" 'night' and 'storm' tokyonight styles (colors/tokyonight.vim computes
" them from bg/bg_dark the same way); this file re-reads g:tokyonight_style
" so the statusline theme matches whichever style the colorscheme applied.
" Every other color below (blue/green/yellow/magenta/red/green1/fg_gutter/
" fg_sidebar) is identical in both styles upstream.
"
" Color tuples are [ '#rrggbb', ctermcolor ] pairs, per lightline's own
" colorscheme contract; cterm indices are nearest-xterm256 approximations
" computed the same way colors/tokyonight.vim's s:approx() does.

let s:style = get(g:, 'tokyonight_style', 'night')
if s:style !=# 'storm'
  let s:style = 'night'
endif

if s:style ==# 'storm'
  let s:black       = [ '#1d202f', 234 ]
  let s:bg_status   = [ '#1f2335', 235 ]
else
  let s:black       = [ '#15161e', 233 ]
  let s:bg_status   = [ '#16161e', 233 ]
endif

let s:blue       = [ '#7aa2f7', 111 ]
let s:green      = [ '#9ece6a', 149 ]
let s:yellow     = [ '#e0af68', 179 ]
let s:magenta    = [ '#bb9af7', 141 ]
let s:red        = [ '#f7768e', 210 ]
let s:red1       = [ '#db4b4b', 167 ]
let s:green1     = [ '#73daca', 80 ]
let s:fg_gutter  = [ '#3b4261', 238 ]
let s:fg_sidebar = [ '#a9b1d6', 146 ]

let s:p = {'normal': {}, 'inactive': {}, 'insert': {}, 'replace': {}, 'visual': {}, 'tabline': {}}

" -- normal (lualine: a=bg:blue/fg:black, b=bg:fg_gutter/fg:blue) ------------
let s:p.normal.left    = [ [ s:black, s:blue, 'bold' ], [ s:blue, s:fg_gutter ] ]
let s:p.normal.right   = [ [ s:black, s:blue, 'bold' ], [ s:blue, s:fg_gutter ] ]
let s:p.normal.middle  = [ [ s:fg_sidebar, s:bg_status ] ]
let s:p.normal.error   = [ [ s:red1, s:bg_status ] ]
let s:p.normal.warning = [ [ s:yellow, s:bg_status ] ]

" -- insert (lualine: a=bg:green/fg:black, b=bg:fg_gutter/fg:green) ----------
let s:p.insert.left  = [ [ s:black, s:green, 'bold' ], [ s:green, s:fg_gutter ] ]
let s:p.insert.right = copy(s:p.insert.left)

" -- replace (lualine: a=bg:red/fg:black, b=bg:fg_gutter/fg:red) -------------
let s:p.replace.left  = [ [ s:black, s:red, 'bold' ], [ s:red, s:fg_gutter ] ]
let s:p.replace.right = copy(s:p.replace.left)

" -- visual (lualine: a=bg:magenta/fg:black, b=bg:fg_gutter/fg:magenta) ------
let s:p.visual.left  = [ [ s:black, s:magenta, 'bold' ], [ s:magenta, s:fg_gutter ] ]
let s:p.visual.right = copy(s:p.visual.left)

" -- inactive (lualine: a=bg:bg_statusline/fg:blue, b/c=bg:bg_statusline/
"    fg:fg_gutter) ----------------------------------------------------------
let s:p.inactive.left   = [ [ s:blue, s:bg_status ], [ s:fg_gutter, s:bg_status ] ]
let s:p.inactive.middle = [ [ s:fg_gutter, s:bg_status ] ]
let s:p.inactive.right  = copy(s:p.inactive.left)

" -- tabline ------------------------------------------------------------
let s:p.tabline.left   = [ [ s:fg_sidebar, s:fg_gutter ] ]
let s:p.tabline.tabsel = [ [ s:black, s:blue, 'bold' ] ]
let s:p.tabline.middle = [ [ s:fg_gutter, s:bg_status ] ]
let s:p.tabline.right  = copy(s:p.normal.right)

let g:lightline#colorscheme#tokyonight#palette = lightline#colorscheme#flatten(s:p)
