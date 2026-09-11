" ============================================================================
" colors/tokyonight.vim -- Tokyo Night for vim-classic
" ============================================================================
" A faithful, in-repo, legacy-Vimscript port of folke/tokyonight.nvim
" (https://github.com/folke/tokyonight.nvim), MIT licensed.
"
" WHY THIS FILE EXISTS instead of a plugin: the previously-vendored
" `ghifarit53/tokyonight-vim` maps highlight groups to colors that do not
" match folke/tokyonight.nvim's actual group->color assignments (e.g. its
" `Identifier` and `Keyword` colors are swapped relative to upstream, and it
" predates Treesitter entirely, so kickstart.nvim users -- whose muscle
" memory is "keywords are purple, functions are blue, fields are teal" --
" would see a noticeably different-looking Go/Lua/etc. buffer). This file
" reads the palette and group tables straight from folke/tokyonight.nvim's
" Lua sources (colors/{storm,night}.lua, colors/init.lua, and
" groups/{base,treesitter,semantic_tokens}.lua) and re-expresses them as
" legacy `:highlight` commands, then extends the mapping onto Vim's
" *regex-based* :syntax groups (vim-polyglot/vim-go for Go, etc.) using
" tokyonight's Treesitter capture colors, so a Go buffer here looks close to
" what kickstart.nvim shows.
"
" Groups covered:
"   - Vim's standard highlight groups (see groups/base.lua upstream)
"   - Vim's builtin *syntax* groups (Statement, Keyword, Type, ...), colored
"     per tokyonight's Treesitter captures (@keyword, @function, ...) rather
"     than upstream's own (older, less granular) `base.lua` values for those
"     same groups -- see the "TREESITTER-INFORMED SYNTAX GROUPS" section
"     below for why, group by group.
"   - vim-go's (bundled by vim-polyglot) Go-specific syntax groups
"   - vim-lsp / vim-lsp-settings groups (diagnostics, references, semantic
"     tokens where vim-lsp defines matching group names)
"   - vim-gitgutter, ALE, vim-which-key, indentLine/Conceal,
"     vim-highlightedyank
"   - Vim's 'g:terminal_ansi_colors'
"
" g:tokyonight_style                    'night' (default) or 'storm'.
"                                        Both palettes are upstream's; only
"                                        bg / bg_dark / bg_dark1 differ
"                                        between them.
" g:tokyonight_transparent_background   0 (default) or 1.
" g:tokyonight_enable_italic            0 (default) or 1 -- master italic
"                                        switch (matches the old
"                                        ghifarit53/tokyonight-vim variable
"                                        name/semantics so nothing else in
"                                        this repo has to change).
" g:tokyonight_disable_italic_comment   0 (default) or 1 -- when italics are
"                                        otherwise enabled, this can still
"                                        force Comment to be upright.
"                                        Comments are therefore italic only
"                                        when enable_italic=1 AND
"                                        disable_italic_comment=0.
" ============================================================================

set background=dark
highlight clear
if exists('syntax_on')
  syntax reset
endif
let g:colors_name = 'tokyonight'

" ---------------------------------------------------------------------------
" Config switches
" ---------------------------------------------------------------------------
let s:style = get(g:, 'tokyonight_style', 'night')
if s:style !=# 'storm'
  let s:style = 'night'
endif
let s:transparent = get(g:, 'tokyonight_transparent_background', 0)
let s:enable_italic = get(g:, 'tokyonight_enable_italic', 0)
let s:disable_italic_comment = get(g:, 'tokyonight_disable_italic_comment', 0)

let s:comment_attr = (s:enable_italic && !s:disable_italic_comment) ? 'italic' : 'NONE'
let s:italic_attr = s:enable_italic ? 'italic' : 'NONE'

" ---------------------------------------------------------------------------
" cterm (256-color) approximation -- so this degrades gracefully without
" 'termguicolors'. Maps an arbitrary #rrggbb to the nearest xterm-256 index
" out of the 6x6x6 color cube (16-231) and the 24-step grayscale ramp
" (232-255). We deliberately skip the 16 basic ANSI slots (0-15): their RGB
" values vary by terminal/theme, so they're not reliable approximation
" targets; the cube+ramp alone already gets within a few RGB units of any
" input color.
" ---------------------------------------------------------------------------
let s:cube_levels = [0, 95, 135, 175, 215, 255]

function! s:nearest_level(v) abort
  let l:best = 0
  let l:bestdiff = 999
  let l:i = 0
  while l:i < len(s:cube_levels)
    let l:d = abs(s:cube_levels[l:i] - a:v)
    if l:d < l:bestdiff
      let l:bestdiff = l:d
      let l:best = l:i
    endif
    let l:i += 1
  endwhile
  return l:best
endfunction

function! s:hex2rgb(hex) abort
  let l:h = a:hex
  if l:h[0] ==# '#'
    let l:h = l:h[1:]
  endif
  return [str2nr(l:h[0:1], 16), str2nr(l:h[2:3], 16), str2nr(l:h[4:5], 16)]
endfunction

function! s:rgb2xterm(r, g, b) abort
  let l:ri = s:nearest_level(a:r)
  let l:gi = s:nearest_level(a:g)
  let l:bi = s:nearest_level(a:b)
  let l:cube_idx = 16 + (36 * l:ri) + (6 * l:gi) + l:bi
  let l:cr = s:cube_levels[l:ri]
  let l:cg = s:cube_levels[l:gi]
  let l:cb = s:cube_levels[l:bi]
  let l:cube_dist = (a:r - l:cr) * (a:r - l:cr) + (a:g - l:cg) * (a:g - l:cg) + (a:b - l:cb) * (a:b - l:cb)

  let l:gray = (a:r + a:g + a:b) / 3
  let l:gray_step = (l:gray - 8) / 10
  if l:gray_step < 0 | let l:gray_step = 0 | endif
  if l:gray_step > 23 | let l:gray_step = 23 | endif
  let l:gray_idx = 232 + l:gray_step
  let l:gv = 8 + (l:gray_step * 10)
  let l:gray_dist = (a:r - l:gv) * (a:r - l:gv) + (a:g - l:gv) * (a:g - l:gv) + (a:b - l:gv) * (a:b - l:gv)

  return l:gray_dist < l:cube_dist ? l:gray_idx : l:cube_idx
endfunction

function! s:approx(hex) abort
  if a:hex ==# '' || a:hex ==# 'NONE'
    return 'NONE'
  endif
  let l:rgb = s:hex2rgb(a:hex)
  return s:rgb2xterm(l:rgb[0], l:rgb[1], l:rgb[2])
endfunction

" ---------------------------------------------------------------------------
" s:hl(group, fg, bg, attr [, sp])   -- emit one `highlight!` command.
" Pass '' for fg/bg/attr to mean "NONE". `attr` is a comma-separated list of
" gui/cterm attribute names (e.g. 'bold,italic') applied to both gui= and
" cterm=. `sp` (optional) sets guisp= for undercurl/underline colors.
" ---------------------------------------------------------------------------
function! s:hl(group, fg, bg, attr, ...) abort
  let l:sp = a:0 >= 1 ? a:1 : ''
  let l:cmd = 'highlight! ' . a:group
  let l:cmd .= ' guifg=' . (a:fg ==# '' ? 'NONE' : a:fg)
  let l:cmd .= ' ctermfg=' . (a:fg ==# '' ? 'NONE' : s:approx(a:fg))
  let l:cmd .= ' guibg=' . (a:bg ==# '' ? 'NONE' : a:bg)
  let l:cmd .= ' ctermbg=' . (a:bg ==# '' ? 'NONE' : s:approx(a:bg))
  let l:cmd .= ' gui=' . (a:attr ==# '' ? 'NONE' : a:attr)
  let l:cmd .= ' cterm=' . (a:attr ==# '' ? 'NONE' : a:attr)
  if l:sp !=# ''
    let l:cmd .= ' guisp=' . l:sp
  endif
  execute l:cmd
endfunction

function! s:link(from, to) abort
  execute 'highlight! link ' . a:from . ' ' . a:to
endfunction

" ---------------------------------------------------------------------------
" Palette -- values transcribed verbatim from folke/tokyonight.nvim's
" lua/tokyonight/colors/{storm,night}.lua (base palette; storm and night
" differ only in bg/bg_dark/bg_dark1) and lua/tokyonight/colors/init.lua
" (derived colors -- diff.*, black, border_highlight, error/warning/etc).
" Blends (util.blend_bg/blend_fg -- linear RGB interpolation toward a
" background/foreground color) were computed to fixed hex values offline;
" each is annotated with the source expression it replaces.
" ---------------------------------------------------------------------------
let s:base = {
  \ 'blue':           '#7aa2f7',
  \ 'blue0':          '#3d59a1',
  \ 'blue1':          '#2ac3de',
  \ 'blue2':          '#0db9d7',
  \ 'blue5':          '#89ddff',
  \ 'blue6':          '#b4f9f8',
  \ 'blue7':          '#394b70',
  \ 'comment':        '#565f89',
  \ 'cyan':           '#7dcfff',
  \ 'dark3':          '#545c7e',
  \ 'dark5':          '#737aa2',
  \ 'fg':             '#c0caf5',
  \ 'fg_dark':        '#a9b1d6',
  \ 'fg_gutter':      '#3b4261',
  \ 'green':          '#9ece6a',
  \ 'green1':         '#73daca',
  \ 'green2':         '#41a6b5',
  \ 'magenta':        '#bb9af7',
  \ 'magenta2':       '#ff007c',
  \ 'orange':         '#ff9e64',
  \ 'purple':         '#9d7cd8',
  \ 'red':            '#f7768e',
  \ 'red1':           '#db4b4b',
  \ 'teal':           '#1abc9c',
  \ 'terminal_black': '#414868',
  \ 'yellow':         '#e0af68',
  \ 'bg_highlight':   '#292e42',
  \ 'git_add':        '#449dab',
  \ 'git_change':     '#6183bb',
  \ 'git_delete':     '#914c54',
  \ }

" Per-style values: bg/bg_dark/bg_dark1 (upstream) plus everything computed
" FROM them (util.blend_bg(..., amount) blends a foreground color toward the
" *current* `bg`, so these change when bg changes between styles):
"   diff_add     = blend_bg(green2 #41a6b5, 0.25)
"   diff_delete  = blend_bg(red1   #db4b4b, 0.25)
"   diff_change  = blend_bg(blue7  #394b70, 0.15)
"   black        = blend_bg(bg, 0.8, "#000000")
"   border_hl    = blend_bg(blue1  #2ac3de, 0.8)     (also reused as
"                  @type.builtin's color -- same expression upstream)
"   bg_visual    = blend_bg(blue0  #3d59a1, 0.4)
let s:styles = {
  \ 'night': {
  \   'bg':               '#1a1b26',
  \   'bg_dark':          '#16161e',
  \   'bg_dark1':         '#0C0E14',
  \   'diff_add':         '#243e4a',
  \   'diff_delete':      '#4a272f',
  \   'diff_change':      '#1f2231',
  \   'black':            '#15161e',
  \   'border_highlight': '#27a1b9',
  \   'bg_visual':        '#283457',
  \   'virt_error':       '#2d202a',
  \   'virt_warning':     '#2e2a2d',
  \   'virt_info':        '#192b38',
  \   'virt_hint':        '#1a2b32',
  \   'inlayhint_bg':     '#1d202d',
  \ },
  \ 'storm': {
  \   'bg':               '#24283b',
  \   'bg_dark':          '#1f2335',
  \   'bg_dark1':         '#1b1e2d',
  \   'diff_add':         '#2b485a',
  \   'diff_delete':      '#52313f',
  \   'diff_change':      '#272d43',
  \   'black':            '#1d202f',
  \   'border_highlight': '#29a4bd',
  \   'bg_visual':        '#2e3c64',
  \   'virt_error':       '#362c3d',
  \   'virt_warning':     '#373640',
  \   'virt_info':        '#22374b',
  \   'virt_hint':        '#233745',
  \   'inlayhint_bg':     '#262c40',
  \ },
  \ }

let s:c = copy(s:base)
call extend(s:c, s:styles[s:style])

let s:c.diff_text = s:c.blue7
let s:c.git_ignore = s:c.dark3
let s:c.bg_statusline = s:c.bg_dark
let s:c.bg_popup = s:c.bg_dark
let s:c.bg_sidebar = s:c.bg_dark
let s:c.bg_float = s:c.bg_dark
let s:c.fg_sidebar = s:c.fg_dark
let s:c.fg_float = s:c.fg
let s:c.bg_search = s:c.blue0
let s:c.error = s:c.red1
let s:c.todo = s:c.blue
let s:c.warning = s:c.yellow
let s:c.info = s:c.blue2
let s:c.hint = s:c.teal
" @type.builtin uses the same blend_bg(blue1, 0.8) expression as
" border_highlight, so they share a value upstream.
let s:c.type_builtin = s:c.border_highlight
" @lsp.type.interface = util.blend_fg(blue1, 0.7) -- blend blue1 toward fg.
let s:c.lsp_interface = '#57c5e5'

" ============================================================================
" STANDARD VIM HIGHLIGHT GROUPS (folke's groups/base.lua)
" ============================================================================
let s:none = ''

call s:hl('Normal',       s:c.fg,      s:transparent ? s:none : s:c.bg, '')
call s:hl('NormalNC',     s:c.fg,      s:transparent ? s:none : s:c.bg, '')
call s:hl('Terminal',     s:c.fg,      s:transparent ? s:none : s:c.bg, '')
call s:hl('NormalFloat',  s:c.fg_float, s:c.bg_float, '')
call s:hl('FloatBorder',  s:c.border_highlight, s:c.bg_float, '')
call s:hl('ColorColumn',  s:none,      s:c.black, '')
" base.lua uses dark5 for Conceal, but this repo's indentLine module (an
" optional kickstart module) paints indent guides through Conceal too, and
" fg_gutter reads much better there against bg -- deviates from base.lua's
" plain dark5 on purpose.
call s:hl('Conceal',      s:c.fg_gutter, s:none, '')
call s:hl('Cursor',       s:c.bg,      s:c.fg, '')
call s:link('lCursor', 'Cursor')
call s:link('CursorIM', 'Cursor')
call s:hl('CursorColumn', s:none,      s:c.bg_highlight, '')
call s:hl('CursorLine',   s:none,      s:c.bg_highlight, '')
call s:hl('Directory',    s:c.blue,    s:none, '')
call s:hl('DiffAdd',      s:none,      s:c.diff_add, '')
call s:hl('DiffChange',   s:none,      s:c.diff_change, '')
call s:hl('DiffDelete',   s:none,      s:c.diff_delete, '')
call s:hl('DiffText',     s:none,      s:c.diff_text, '')
call s:hl('EndOfBuffer',  s:c.bg,      s:none, '')
call s:hl('ErrorMsg',     s:c.error,   s:none, '')
call s:hl('VertSplit',    s:c.black,   s:none, '')
call s:link('WinSeparator', 'VertSplit')
call s:hl('Folded',       s:c.blue,    s:c.fg_gutter, '')
call s:hl('FoldColumn',   s:c.comment, s:transparent ? s:none : s:c.bg, '')
call s:hl('SignColumn',   s:c.fg_gutter, s:transparent ? s:none : s:c.bg, '')
call s:hl('Substitute',   s:c.black,   s:c.red, '')
call s:hl('LineNr',       s:c.fg_gutter, s:none, '')
call s:hl('CursorLineNr', s:c.orange,  s:none, 'bold')
call s:hl('MatchParen',   s:c.orange,  s:none, 'bold')
call s:hl('ModeMsg',      s:c.fg_dark, s:none, 'bold')
call s:hl('MoreMsg',      s:c.blue,    s:none, '')
call s:hl('NonText',      s:c.dark3,   s:none, '')
call s:hl('Pmenu',        s:c.fg,      s:c.bg_popup, '')
call s:hl('PmenuSel',     s:none,      s:c.fg_gutter, '')
call s:hl('PmenuSbar',    s:none,      s:c.bg_popup, '')
call s:hl('PmenuThumb',   s:none,      s:c.fg_gutter, '')
call s:hl('Question',     s:c.blue,    s:none, '')
call s:hl('QuickFixLine', s:none,      s:c.bg_visual, 'bold')
call s:hl('Search',       s:c.fg,      s:c.bg_search, '')
call s:hl('IncSearch',    s:c.black,   s:c.orange, '')
call s:link('CurSearch', 'IncSearch')
call s:hl('SpecialKey',   s:c.dark3,   s:none, '')
call s:hl('SpellBad',     s:none,      s:none, 'undercurl', s:c.error)
call s:hl('SpellCap',     s:none,      s:none, 'undercurl', s:c.warning)
call s:hl('SpellLocal',   s:none,      s:none, 'undercurl', s:c.info)
call s:hl('SpellRare',    s:none,      s:none, 'undercurl', s:c.hint)
call s:hl('StatusLine',   s:c.fg_sidebar, s:c.bg_statusline, '')
call s:hl('StatusLineNC', s:c.fg_gutter,  s:c.bg_statusline, '')
call s:link('StatusLineTerm', 'StatusLine')
call s:link('StatusLineTermNC', 'StatusLineNC')
call s:hl('TabLine',      s:c.fg_gutter, s:c.bg_statusline, '')
call s:hl('TabLineFill',  s:none, s:transparent ? s:none : s:c.black, '')
call s:hl('TabLineSel',   s:c.black,   s:c.blue, '')
call s:hl('Title',        s:c.blue,    s:none, 'bold')
call s:hl('Visual',       s:none,      s:c.bg_visual, '')
call s:hl('VisualNOS',    s:none,      s:c.bg_visual, '')
call s:hl('WarningMsg',   s:c.warning, s:none, '')
call s:hl('Whitespace',   s:c.fg_gutter, s:none, '')
call s:hl('WildMenu',     s:none,      s:c.bg_visual, '')
call s:link('ToolbarLine', 'StatusLine')
call s:link('ToolbarButton', 'TabLineSel')
call s:link('PopupNotification', 'WarningMsg')

call s:hl('Bold',       s:c.fg, s:none, 'bold')
call s:hl('Italic',     s:c.fg, s:none, s:italic_attr)
call s:hl('Character',  s:c.green, s:none, '')
call s:hl('Constant',   s:c.orange, s:none, '')
call s:hl('Debug',      s:c.orange, s:none, '')
" Delimiter is set for real in the TREESITTER-INFORMED section below
" (blue5, per @punctuation.delimiter) rather than here (base.lua links it
" to Special/blue1) -- see the comment down there.
call s:hl('Error',      s:c.error, s:none, '')
" Function: folke colors this s:c.blue -- same value @function uses, so
" plain :syntax highlighting and Treesitter agree here without an override.
call s:hl('Function',   s:c.blue, s:none, '')
" Identifier: base.lua says magenta, but @variable (what Treesitter actually
" tags a plain variable use as) is fg -- see TREESITTER-INFORMED section.
call s:hl('Identifier', s:c.fg, s:none, '')
call s:hl('Operator',   s:c.blue5, s:none, '')
call s:hl('PreProc',    s:c.cyan, s:none, '')
call s:hl('Special',    s:c.blue1, s:none, '')
" Statement: base.lua says magenta; treesitter.lua links @keyword.conditional
" etc. to Vim's Conditional/Repeat/Exception groups below and gives the bare
" @keyword its OWN purple, so Statement (Vim's syntax files mostly use
" Keyword/Conditional/Repeat rather than bare Statement) stays magenta here.
call s:hl('Statement',  s:c.magenta, s:none, '')
call s:hl('String',     s:c.green, s:none, '')
call s:hl('Todo',       s:c.bg, s:c.yellow, '')
call s:hl('Type',       s:c.blue1, s:none, '')
call s:hl('Underlined', s:none, s:none, 'underline')

" ============================================================================
" TREESITTER-INFORMED SYNTAX GROUPS
" ============================================================================
" Vim has no Treesitter, but its builtin *syntax* groups
" (Keyword/Conditional/.../SpecialChar/...) are exactly what vim-polyglot's
" regex syntax files (and Go's below) actually use. To make a kickstart.nvim
" user feel at home, these are colored per tokyonight's Treesitter capture
" groups (groups/treesitter.lua) rather than upstream's own (older, coarser)
" base.lua colors for the SAME group name, wherever the two differ:
"   Keyword: base.lua = cyan; but @keyword (what a Treesitter grammar tags a
"     bare keyword like `func`/`return` as) = purple. Purple is what
"     kickstart.nvim users actually see, so Keyword -> purple here.
"   Conditional/Repeat/Exception/Label: @keyword.conditional etc. link to
"     these Vim groups upstream (not the reverse), so magenta is correct
"     both ways -- no override needed vs. base.lua's own Statement=magenta.
"   Include/Define/Macro/PreCondit: @keyword.import/@keyword.directive.*
"     link to Include/Define -- cyan (PreProc's color), matches base.lua.
"   Delimiter: @punctuation.bracket/.delimiter use fg_dark/blue5; base.lua
"     links Delimiter -> Special (blue1). We follow treesitter.lua's
"     @punctuation.delimiter (blue5) since that's what most punctuation in
"     a Treesitter buffer actually renders as.
call s:hl('Keyword',      s:c.purple,  s:none, s:italic_attr)
call s:hl('Conditional',  s:c.magenta, s:none, s:italic_attr)
call s:hl('Repeat',       s:c.magenta, s:none, s:italic_attr)
call s:hl('Label',        s:c.blue,    s:none, '')
call s:hl('Exception',    s:c.magenta, s:none, s:italic_attr)
call s:hl('Include',      s:c.cyan,    s:none, s:italic_attr)
call s:hl('Define',       s:c.cyan,    s:none, '')
call s:hl('Macro',        s:c.blue,    s:none, '')
call s:hl('PreCondit',    s:c.cyan,    s:none, '')
call s:hl('StorageClass', s:c.purple,  s:none, '')
call s:hl('Structure',    s:c.purple,  s:none, '')
call s:hl('Typedef',      s:c.blue1,   s:none, '')
call s:hl('SpecialChar',  s:c.magenta, s:none, '')
call s:hl('Tag',          s:c.blue,    s:none, '')
call s:hl('Delimiter',    s:c.blue5,   s:none, '')
call s:hl('SpecialComment', s:c.comment, s:none, '')
call s:hl('Ignore',       s:c.comment, s:none, '')
call s:hl('Comment',      s:c.comment, s:none, s:comment_attr)
call s:hl('Number',       s:c.orange,  s:none, '')
call s:hl('Boolean',      s:c.orange,  s:none, '')
call s:hl('Float',        s:c.orange,  s:none, '')

" ============================================================================
" Terminal ANSI colors (folke's `terminal` table in colors/init.lua).
" *_bright values use util.brighten() (HSLuv lightness+saturation boost);
" approximated here as a plain RGB lerp toward white -- close but not an
" exact HSLuv match, noted since Vimscript has no HSLuv implementation.
" ============================================================================
let g:terminal_ansi_colors = [
  \ s:c.black, s:c.red, s:c.green, s:c.yellow,
  \ s:c.blue, s:c.magenta, s:c.cyan, s:c.fg_dark,
  \ s:c.terminal_black, '#f88ea2', '#afd684', '#e5bd83',
  \ '#91b2f8', '#c7acf8', '#94d7ff', s:c.fg,
  \ ]
if exists('*term_setansicolors')
  " (per-terminal-buffer API; g:terminal_ansi_colors above covers
  " :terminal buffers created after this colorscheme is applied)
endif

" ============================================================================
" GO SYNTAX GROUPS (vim-go, bundled by vim-polyglot)
" ============================================================================
" vim-go's syntax/go.vim ships its OWN `hi def link <goGroup> <VimGroup>`
" defaults (e.g. `hi def link goFunction Function`, `hi def link goVar
" Keyword`). Because those use `hi def` (define only if the group doesn't
" already have a highlight) and are dynamic links (they track whatever color
" the target group currently has, not a snapshot), most Go coloring above
" already falls out for free from the base-group colors set earlier in this
" file: goVar/goConst/goDeclaration -> Keyword (purple), goStatement ->
" Statement (magenta), goConditional/goRepeat/goLabel -> Conditional/Repeat/
" Label (magenta/magenta/blue), goType/goSignedInts/goUnsignedInts/goFloats/
" goComplexes -> Type (blue1), goBoolean -> Boolean (orange),
" goPredefinedIdentifiers (nil/iota) -> goBoolean -> orange, goFunction ->
" Function (blue), goOperator -> Operator (blue5), goString/goRawString ->
" String (green), goComment -> Comment, goTodo -> Todo, goTypeName/
" goReceiverType/goTypeConstructor -> Type (blue1), goDeclType/goTypeDecl ->
" Keyword (purple), goGenerate/goBuildKeyword -> PreProc (cyan).
"
" The groups below need an EXPLICIT, forced (`highlight!`, not `hi def`)
" override because vim-go's own default link points them at a Vim group
" that doesn't match tokyonight's Treesitter-informed color for that same
" *kind* of token. A forced `highlight!` here always wins over vim-go's
" `hi def link`, regardless of load order (colorscheme vs. syntax file).
"
"   goPackage/goImport: default link -> Statement (magenta). Treesitter's
"     @keyword.import (what `package`/`import` are tagged as) links to
"     Include instead -- cyan.
call s:link('goPackage', 'Include')
call s:link('goImport', 'Include')
"   goFunctionCall: default link -> Type (blue1). @function.call = @function
"     (blue) upstream -- a call should look like the function it calls.
call s:hl('goFunctionCall', s:c.blue, s:none, '')
"   goField: default link -> Identifier (fg). @variable.member = green1.
call s:hl('goField', s:c.green1, s:none, '')
"   goParamName: default link -> Identifier (fg). @variable.parameter =
"     yellow. (goReceiverVar dynamically links to goParamName in vim-go
"     itself, so the receiver variable `p` picks up the same yellow --
"     vim-go doesn't distinguish "receiver" from "parameter" as its own
"     kind, so this is the closest match available.)
call s:hl('goParamName', s:c.yellow, s:none, '')
"   goParamType has NO default link in vim-go at all (it's a container
"     match whose *contents* -- goType/goSignedInts/etc -- already carry
"     Type's blue1 for builtin types like `float64`). We still color the
"     container itself Type-blue1 as a fallback for non-builtin/pointer
"     param types vim-go's sub-matches don't catch (e.g. `*Point`).
call s:hl('goParamType', s:c.type_builtin, s:none, '')
"   goBuiltins (len/append/make/...): default link -> Identifier (fg).
"     @function.builtin links to Special (blue1) upstream -- note this is
"     blue1 (#2ac3de), not plain blue (#7aa2f7); Special, not Function.
call s:hl('goBuiltins', s:c.blue1, s:none, '')
"   Escape sequences vs. format specifiers: vim-go funnels BOTH through the
"     shared goSpecialString -> Special (blue1) chain, but tokyonight
"     Treesitter-wise these are two different captures:
"       @string.escape (\n, \t, \xFF, ...)   = magenta
"       @lsp.type.formatSpecifier -> @markup.list (%d, %v, ...) = blue5
"     so they're split out here rather than left on the shared default.
call s:hl('goEscapeC', s:c.magenta, s:none, '')
call s:hl('goEscapeOctal', s:c.magenta, s:none, '')
call s:hl('goEscapeX', s:c.magenta, s:none, '')
call s:hl('goEscapeU', s:c.magenta, s:none, '')
call s:hl('goEscapeBigU', s:c.magenta, s:none, '')
call s:hl('goFormatSpecifier', s:c.blue5, s:none, '')
"
" NOT overridden / not applicable (see final report for detail):
"   - goSimpleBuiltinTypes, goConstants, goStruct, goInterface, goDirective
"     do not exist as syntax groups in this vim-go; struct/interface
"     keywords are goDeclType (already Keyword/purple), and goBuildKeyword
"     is the closest thing to a "directive" group (already PreProc/cyan).
"   - Struct FIELD DECLARATIONS (e.g. the `X, Y int` inside `type Point
"     struct {...}`) are not colored at all by vim-go's goField -- that
"     group only matches `.field` DOT-ACCESS (e.g. `p.X`), not declaration
"     sites. A kickstart.nvim/Treesitter buffer *would* color the
"     declaration-site name too (@variable.member); vim-go's regex
"     highlighting cannot reach that case, so it stays plain fg here.

" ============================================================================
" GITGUTTER (airblade/vim-gitgutter) -- folke's groups/gitgutter.lua
" ============================================================================
call s:hl('GitGutterAdd',    s:c.git_add,    s:none, '')
call s:hl('GitGutterChange', s:c.git_change, s:none, '')
call s:hl('GitGutterDelete', s:c.git_delete, s:none, '')
call s:hl('GitGutterAddLineNr',    s:c.git_add,    s:none, '')
call s:hl('GitGutterChangeLineNr', s:c.git_change, s:none, '')
call s:hl('GitGutterDeleteLineNr', s:c.git_delete, s:none, '')
" Not in folke's gitgutter.lua (Neovim's gitsigns.nvim has no "both changed
" and about to be deleted" hunk kind the way vim-gitgutter's
" ChangeDelete does); approximated as the delete color since that's the
" more surprising half of the hunk.
call s:link('GitGutterChangeDelete', 'GitGutterDelete')

" ============================================================================
" ALE (dense-analysis/ale) -- folke's groups/ale.lua
" ============================================================================
" ALE's own `if !hlexists(...)` defaults already link ALEError -> SpellBad
" and ALEWarning -> SpellCap (both already colored correctly above via
" DiagnosticError-equivalent sp= colors), and ALEInfo -> ALEWarning, so
" nothing more is needed for the underline groups. Only the sign colors are
" in folke's own ale.lua, so only those are set explicitly here.
call s:hl('ALEErrorSign',   s:c.error,   s:none, '')
call s:hl('ALEWarningSign', s:c.warning, s:none, '')
" Not in folke's ale.lua; added for consistency with the diagnostic palette.
call s:hl('ALEInfoSign',    s:c.info,    s:none, '')

" ============================================================================
" WHICH-KEY (liuchengxu/vim-which-key) -- folke's groups/which-key.lua
" ============================================================================
" NOTE: vim-which-key's real group is spelled "WhichKeySeperator" (missing
" the second "a") -- verified against plugged/vim-which-key/syntax/
" which_key.vim; that's not a typo introduced here.
call s:hl('WhichKey',          s:c.cyan,    s:none, '')
call s:hl('WhichKeyGroup',     s:c.blue,    s:none, '')
call s:hl('WhichKeyDesc',      s:c.magenta, s:none, '')
call s:hl('WhichKeySeperator', s:c.comment, s:none, '')
" WhichKeyFloating already defaults (in vim-which-key itself) to Pmenu,
" which is already colored above -- left alone on purpose.

" ============================================================================
" MISC SMALL PLUGINS
" ============================================================================
" indentLine (optional kickstart module: kickstart/plugins/indent_line.vim)
" paints indent guides through Conceal, already set to fg_gutter above.
"
" vim-highlightedyank has no Neovim-side equivalent group in tokyonight (the
" nvim on_yank() highlight in kickstart.nvim uses whatever `hl-group` is
" passed to vim.hl.on_yank(), commonly 'IncSearch' or 'Visual'); Visual is
" used here since a yank flash is conceptually closer to a visual selection
" flash than to a search match.
call s:link('HighlightedyankRegion', 'Visual')

" ============================================================================
" VIM-LSP / VIM-LSP-SETTINGS
" ============================================================================
" Group names below were verified literally against
" plugged/vim-lsp/doc/vim-lsp.txt (case, spelling, and existence) rather
" than assumed from the Neovim-native LSP group names of the same shape.
" Colors follow folke's error/warning/info/hint values from
" lua/tokyonight/colors/init.lua (error=red1, warning=yellow, info=blue2,
" hint=teal) and DiagnosticUnderline*/DiagnosticVirtualText* from
" groups/base.lua for the underline/virtual-text treatment.

" Sign-column + inline text color for each severity (defaults link to
" Error/Todo/Normal/Normal; overridden for the full 4-way diagnostic
" palette instead of piggybacking on Todo for warnings).
call s:hl('LspErrorText',       s:c.error,   s:none, '')
call s:hl('LspWarningText',     s:c.warning, s:none, '')
call s:hl('LspInformationText', s:c.info,    s:none, '')
call s:hl('LspHintText',        s:c.hint,    s:none, '')

" Underline (undercurl) below the offending text -- mirrors base.lua's
" DiagnosticUnderline{Error,Warn,Info,Hint} (undercurl + sp=color, fg/bg
" left alone).
call s:hl('LspErrorHighlight',       s:none, s:none, 'undercurl', s:c.error)
call s:hl('LspWarningHighlight',     s:none, s:none, 'undercurl', s:c.warning)
call s:hl('LspInformationHighlight', s:none, s:none, 'undercurl', s:c.info)
call s:hl('LspHintHighlight',        s:none, s:none, 'undercurl', s:c.hint)

" End-of-line virtual text -- mirrors base.lua's
" DiagnosticVirtualText{Error,Warn,Info,Hint} (bg = blend_bg(color, 0.1),
" fg = color).
call s:hl('LspErrorVirtualText',       s:c.error,   s:c.virt_error,   '')
call s:hl('LspWarningVirtualText',     s:c.warning, s:c.virt_warning, '')
call s:hl('LspInformationVirtualText', s:c.info,    s:c.virt_info,    '')
call s:hl('LspHintVirtualText',        s:c.hint,    s:c.virt_hint,    '')

" NOTE: LspErrorLine / LspWarningLine / LspInformationLine / LspHintLine
" (full-line background highlight) do NOT exist in this version of vim-lsp
" (verified: zero matches in doc or autoload/) -- skipped rather than
" defining highlight groups vim-lsp never reads.

" Document highlight (references of the symbol under the cursor) -- mirrors
" Neovim's LspReferenceText/Read/Write (all bg = fg_gutter upstream).
call s:hl('lspReference', s:none, s:c.fg_gutter, '')

" Code-action-available sign. folke has no direct equivalent (this is a
" vim-lsp-only concept); approximated as orange, evoking the usual
" "lightbulb" code-action color other editors use.
call s:hl('LspCodeActionText', s:c.orange, s:none, '')

" Inlay hints. NOTE: exact vim-lsp group names are *lowercase-l*
" `lspInlayHintsType` / `lspInlayHintsParameter` (verified against
" plugged/vim-lsp/doc/vim-lsp.txt and autoload/lsp/internal/inlay_hints.vim
" -- NOT `LspInlayHintsType`/`LspInlayHintsParameter` as capitalized
" elsewhere in vim-lsp's naming). Colors mirror base.lua's single
" LspInlayHint group (bg = blend_bg(blue7, 0.1), fg = dark3); tokyonight
" doesn't distinguish inlay-hint kinds any further than that upstream.
call s:hl('lspInlayHintsType',      s:c.dark3, s:c.inlayhint_bg, '')
call s:hl('lspInlayHintsParameter', s:c.dark3, s:c.inlayhint_bg, '')

" Semantic tokens (needs +textprop; see vimrc SECTION 8 for
" g:lsp_semantic_enabled). Only the 20 `LspSemantic*` groups vim-lsp
" actually documents are defined -- grepped verbatim out of
" plugged/vim-lsp/doc/vim-lsp.txt (note LspSemanticEvents is plural in
" vim-lsp's own naming, unlike the singular LSP spec token type "event").
" There is no LspSemanticMacro or LspSemanticDecorator group in this
" version of vim-lsp even though "macro" and "decorator" are standard LSP
" semantic token types -- so those two are not defined below.
call s:hl('LspSemanticType',         s:c.type_builtin, s:none, '')
" Class/struct/enum/typeParameter/events: folke's semantic_tokens.lua only
" special-cases enum (-> @type) and interface; the rest have no dedicated
" @lsp.type.* entry upstream, so they fall back to plain Type/blue1 here
" (approximation, noted).
call s:hl('LspSemanticClass',        s:c.type_builtin, s:none, '')
call s:hl('LspSemanticEnum',         s:c.type_builtin, s:none, '')
call s:hl('LspSemanticInterface',    s:c.lsp_interface, s:none, '')
call s:hl('LspSemanticStruct',       s:c.type_builtin, s:none, '')
call s:hl('LspSemanticTypeParameter', s:c.type_builtin, s:none, '')
call s:hl('LspSemanticParameter',    s:c.yellow, s:none, '')
" @lsp.type.variable = {} upstream ("use treesitter styles for regular
" variables") -- treesitter's own @variable is plain fg.
call s:hl('LspSemanticVariable',     s:c.fg, s:none, '')
call s:hl('LspSemanticProperty',     s:c.green1, s:none, '')
call s:hl('LspSemanticEnumMember',   s:c.orange, s:none, '')
" No folke mapping for LSP's "event" token type; approximated as Type.
call s:hl('LspSemanticEvents',       s:c.type_builtin, s:none, '')
" function/method: no explicit @lsp.type.function|method override upstream
" either (Neovim's own default semantic-token->Treesitter link already
" covers these), so they're colored to match @function/@function.method
" (Function, blue) directly.
call s:hl('LspSemanticFunction',     s:c.blue, s:none, '')
call s:hl('LspSemanticMethod',       s:c.blue, s:none, '')
call s:hl('LspSemanticKeyword',      s:c.purple, s:none, '')
" No dedicated upstream color for a generic "modifier" token; approximated
" to purple (folke colors the one modifier it DOES special-case --
" @lsp.typemod.keyword.async -- as @keyword, i.e. purple).
call s:hl('LspSemanticModifier',     s:c.purple, s:none, '')
call s:hl('LspSemanticComment',      s:c.comment, s:none, s:comment_attr)
call s:hl('LspSemanticString',       s:c.green, s:none, '')
call s:hl('LspSemanticNumber',       s:c.orange, s:none, '')
" @lsp.type.regexp has no override in semantic_tokens.lua; using
" treesitter.lua's @string.regexp (blue6) instead.
call s:hl('LspSemanticRegexp',       s:c.blue6, s:none, '')
call s:hl('LspSemanticOperator',     s:c.blue5, s:none, '')

