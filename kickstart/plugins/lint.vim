" kickstart/plugins/lint.vim
"
" The nvim-lint equivalent. vimrc (SECTION 10) already loads `ale` and sets
" `g:ale_linters_explicit = 1` with an empty `g:ale_linters`, which means
" ALE runs *zero* linters until this file adds some to that dict. Enable by
" uncommenting the `execute 'source' ...` line for this file in vimrc
" (SECTION 15).

let g:ale_linters = {
  \ 'markdown': ['markdownlint'],
  \ 'sh': ['shellcheck'],
  \ 'go': ['govet'],
  \ 'python': ['ruff'],
  \ 'javascript': ['eslint'],
  \ 'typescript': ['eslint'],
  \ 'lua': ['luacheck'],
  \ }

" Lint on save and on enter, not on every keystroke -- matches nvim-lint's
" default kickstart config of linting on BufWritePost/BufReadPost/InsertLeave
" rather than continuously.
let g:ale_lint_on_text_changed = 'never'
let g:ale_lint_on_enter = 1
let g:ale_lint_on_save = 1

" Show which linter produced each message in the echo'd diagnostic.
let g:ale_echo_msg_format = '[%linter%] %s [%severity%]'
