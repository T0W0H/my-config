" =============================================================================
" vimrc — ROS 开发完整工作流（Python / C++ / JSON / CSV / launch）
" =============================================================================
" 原则：简洁、少快捷键、社区标准键位、关键位置写注释
"
" 变更记录:
"   2026-06-01  Scarlet 暖色主题 + 全线统一 (终端/tmux/Vim/Yazi)
"               文件夹颜色改为蛋黄白 #ffecb3
"               Ctrl-N 打开 yazi 自动 cd 到当前文件目录
"               移除 asyncomplete/asyncomplete-lsp (vim-lsp 内置补全)
"               移除旧 GNOME 配置 (drakula, tmux), 仅保留 我的最爱
"   2026-06-01  ROS 工作流全面升级:
"               fzf.vim / snipMate / vim-snippets
"               Python LSP (pyright) + Vim 9.2
"               catkin build + tmux 集成 + 自动格式化
"               tmux 内 Ctrl-N→yazi 联动 / tmux 外 Ctrl-N→NERDTree
" =============================================================================

" ---- Burgundy 主题 (暖色 · 红/洋红主导 · 高饱和 · 酒红底 #380C2A) ---------
set background=dark
set termguicolors
hi Normal guibg=#380C2A ctermbg=0
hi SignColumn guibg=#380C2A ctermbg=0
hi FoldColumn guibg=#380C2A ctermbg=0
hi CursorLine guibg=#2D0822 ctermbg=235

" :terminal 内 ANSI 16 色调（与终端/tmux/yazi 统一）
let g:terminal_ansi_colors = ['#380C2A','#ff5252','#69f0ae','#ffab40','#61AFEF','#ff4081','#40c4ff','#F0E4EC','#7A6B73','#ff8a80','#b9f6ca','#ffd740','#82b1ff','#ff80ab','#84ffff','#ffffff']

" 状态栏始终显示
set laststatus=2
set statusline=%f\ %m%r%h%w\ [%{&ff}]\ [%Y]\ %=%-14.(%l,%c%V%)\ %P
set cursorline

" ---- 基础设置 ---------------------------------------------------------------
set nu
set hlsearch
set incsearch
set ignorecase
set smartcase

" 窗口分割方向
set splitbelow
set splitright

" Buffer / 更新
set hidden
set updatetime=300
set signcolumn=yes

" ---- 缩进 (全空格, 4 空格, ROS Python/C++ 标准) ---------------------------
set expandtab
set tabstop=4
set shiftwidth=4
set softtabstop=4
set autoindent
set smarttab

" 缩进可视化：按 \l 开关空格/tab 显示
set nolist
set listchars=trail:·,extends:»,precedes:«,nbsp:␣
hi SpecialKey guifg=#455a64 ctermfg=238
nnoremap <silent> <Leader>l :set list!<CR>

" 关闭 polyglot 的红色缩进错误高亮（纯空格项目不混用 tab）
let g:python_highlight_indent_errors = 0
let g:python_highlight_space_errors = 0

" ---- 文件类型 ---------------------------------------------------------------
filetype plugin indent on
syntax on

" ---- CSV (rainbow_csv) -------------------------------------------------------
let g:polyglot_disabled = ['csv']
let g:rcsv_max_columns = 100

augroup vim_fix_undo_ftplugin
  autocmd!
  autocmd BufReadPre * unlet! b:undo_ftplugin
augroup END

" ---- fzf --------------------------------------------------------------------
nnoremap <silent> <Leader>f :Files<CR>
nnoremap <silent> <Leader>g :Rg<CR>
nnoremap <silent> <Leader>b :Buffers<CR>
nnoremap <silent> <Leader>h :History<CR>

" ---- 文件浏览器 -------------------------------------------------------------
" tmux 内: Ctrl-N → yazi (底部 1/3, cd 到当前文件目录, yazi 回车→vim remote)
" tmux 外: Ctrl-N → NERDTree
if $TMUX != ''
  call remote_startserver('VIM')
  function! s:open_yazi()
    let l:dir = expand('%:p:h')
    silent execute '!tmux split-window -v -p 33 "cd ' . shellescape(l:dir) . ' && yazi"'
  endfunction
  nnoremap <silent> <C-n> :call <SID>open_yazi()<CR>
else
  nnoremap <silent> <C-n> :NERDTreeToggle<CR>
  let NERDTreeShowHidden=1
endif

" ---- LSP (vim-lsp, 内置补全) ------------------------------------------------
augroup vimrc_lsp_register
  autocmd!
  autocmd VimEnter * call s:register_lsp_servers()
augroup END

function! s:register_lsp_servers() abort
  if executable('clangd')
    call lsp#register_server({
          \ 'name': 'clangd',
          \ 'cmd': {server_info->['clangd', '--background-index', '--clang-tidy']},
          \ 'allowlist': ['c', 'cpp'],
          \ })
  endif
  if executable('pyright-langserver')
    call lsp#register_server({
          \ 'name': 'pyright',
          \ 'cmd': {server_info->['pyright-langserver', '--stdio']},
          \ 'allowlist': ['python'],
          \ })
  endif
endfunction

function! s:on_lsp_buffer_enabled() abort
  setlocal omnifunc=lsp#complete
  setlocal tagfunc=lsp#tagfunc
  nmap <buffer> gd <plug>(lsp-definition)
  nmap <buffer> gD <plug>(lsp-declaration)
  nmap <buffer> K  <plug>(lsp-hover)
  nmap <buffer> gr <plug>(lsp-references)
  nmap <buffer> gi <plug>(lsp-implementation)
  nmap <buffer> <F2> <plug>(lsp-rename)
  nmap <buffer> [g <plug>(lsp-previous-diagnostic)
  nmap <buffer> ]g <plug>(lsp-next-diagnostic)
endfunction

augroup vimrc_lsp
  autocmd!
  autocmd User lsp_buffer_enabled call s:on_lsp_buffer_enabled()
augroup END

let g:lsp_diagnostics_enabled = 1
let g:lsp_diagnostics_echo_cursor = 1
let g:lsp_diagnostics_highlights_enabled = 0
let g:lsp_diagnostics_signs_enabled = 1

" ---- Snippets (snipMate, 纯 Vim 脚本) ---------------------------------------
" snipMate 来自 apt 包 (vim-snipmate), Snippets 来自 vim-snippets
" Tab 展开片段, Ctrl-j/k 跳转占位符
let g:snipMate = { 'snippet_version': 1 }
set runtimepath+=/usr/share/vim/addons

" ---- catkin 构建 (quickfix 错误跳转) ----------------------------------------
let g:catkin_build_errorformat = '%f:%l:%c: %t%*[^:]: %m,%f:%l:%c: %m,%f:%l: %m,CMake Error at %f:%l: %m,%m'

function! s:catkin_build()
  let l:pkg_dir = finddir('src', '.;')
  if empty(l:pkg_dir)
    echom '不在 catkin workspace 中（未找到 src/）'
    return
  endif
  let l:root = fnamemodify(l:pkg_dir, ':p:h')
  let &l:makeprg = 'cd ' . shellescape(l:root) . ' && catkin build --this --no-status'
  let &l:errorformat = g:catkin_build_errorformat
  execute 'lcd' fnameescape(l:root)
  make!
  copen
endfunction

function! s:catkin_build_all()
  let l:pkg_dir = finddir('src', '.;')
  if empty(l:pkg_dir)
    echom '不在 catkin workspace 中'
    return
  endif
  let l:root = fnamemodify(l:pkg_dir, ':p:h')
  let &l:makeprg = 'cd ' . shellescape(l:root) . ' && catkin build --no-status'
  let &l:errorformat = g:catkin_build_errorformat
  execute 'lcd' fnameescape(l:root)
  make!
  copen
endfunction

nnoremap <silent> <Leader>m  :call <SID>catkin_build()<CR>
nnoremap <silent> <Leader>ma :call <SID>catkin_build_all()<CR>

" ---- tmux 集成 --------------------------------------------------------------
function! s:tmux_run(cmd)
  if $TMUX != ''
    silent execute '!tmux split-window -v -p 30 ' . shellescape(a:cmd)
  else
    execute 'belowright terminal ++rows=15'
    call term_sendkeys('', a:cmd . "\<CR>")
  endif
endfunction

nnoremap <silent> <Leader>ts :call <SID>tmux_run('cd ' . shellescape(expand('%:p:h')) . ' && $SHELL')<CR>
nnoremap <silent> <Leader>tr :call <SID>tmux_run('roslaunch ' . shellescape(expand('%:p')))<CR>
nnoremap <silent> <Leader>tv :call <SID>tmux_run('$SHELL')<CR>
nnoremap <silent> <Leader>to :call <SID>tmux_run('source devel/setup.zsh 2>/dev/null; source /opt/ros/noetic/setup.zsh; rosrun ' . input('package: ') . ' ' . input('node: '))<CR>

" ---- 保存时自动格式化 -------------------------------------------------------
augroup vimrc_format
  autocmd!
  autocmd BufWritePre *.py silent! %!autopep8 -
  autocmd BufWritePre *.cpp,*.hpp,*.h,*.cc,*.cxx silent! %!clang-format --style=Google
  autocmd BufWritePre *.json silent! %!python3 -m json.tool
  autocmd BufWritePre *.launch call s:format_launch()
augroup END

function! s:format_launch()
  if &modified
    let l:view = winsaveview()
    let l:had_xml_decl = (getline(1) =~ '^<?xml')
    silent! %!xmllint --format -
    if !l:had_xml_decl && getline(1) =~ '^<?xml'
      1d
    endif
    call winrestview(l:view)
  endif
endfunction

" ---- ROS --------------------------------------------------------------------
let g:ros_catkin_workspaces = ['~/catkin_ws']
