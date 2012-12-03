colorscheme torte
set background=dark

set shortmess=atToOI

set visualbell

set ruler
set wildmode=longest:full,full
set wildmenu


" show line numbers
set nu

set ignorecase
set scs
set showmatch

set cindent

set scrolloff=10

set number
set shiftwidth=2
set tabstop=2
set backspace=2

set expandtab

set hlsearch

set shellcmdflag=-ic

"   Disable autogen:
let g:disable_google_boilerplate=1
"   Disable tool usage statistics logging:
let g:disable_google_logging=1
"   Disable most settings changes:
" let g:disable_google_optional_settings=1

source /usr/share/vim/google/google.vim
" Fix arrow keys in insert mode (bug caused by sessionman?)


" clang_complete options
let g:clang_auto_select = 0
let g:clang_complete_auto = 0
let g:clang_complete_copen = 0
let g:clang_hl_errors = 1
let g:clang_periodic_quickfix = 0
let g:clang_snippets = 0
let g:clang_close_preview = 1
let g:clang_exec = "clang"
let g:clang_use_library = 1
let g:clang_library_path = "/usr/local/lib"
let g:clang_sort_algo = "priority"
let g:clang_complete_macros = 1
let g:clang_complete_patterns = 1
let g:clang_debug = 1
let g:clang_auto_user_options = "path, .clang_complete, gcc, chrome"

" put quickfix window on bottom
:autocmd FileType qf wincmd J

if has("mouse")
  set mouse=a
endif

set incsearch

filetype plugin on
filetype indent on

autocmd BufEnter * let &titlestring = "[vim( " . expand("%:t") . " )]"
autocmd BufEnter * set title

function! CleverTab()
  if strpart(getline('.'), 0, col('.') - 1) =~ '^\s*$'
    return "\<Tab>"
  else
    if &omnifunc != ''
      if pumvisible()
        return "\<C-O>"
      else
        return "\<C-X>\<C-O>"
      endif
    elseif &dictionary != ''
      return "\<C-K>"
    else
      return "\<C-N>"
    endif
  endif
endfunction

inoremap <Tab> <C-R>=CleverTab()<cr>
inoremap <expr> <S-Tab>    pumvisible() ? "\<C-p>" : "\<S-Tab>"
inoremap <expr> <CR>       pumvisible() ? "\<C-y>" : "\<CR>"
inoremap <expr> <Down>     pumvisible() ? "\<C-n>" : "\<Down>"
inoremap <expr> <Up>       pumvisible() ? "\<C-p>" : "\<Up>"
inoremap <expr> <PageDown> pumvisible() ? "\<PageDown>\<C-p>\<C-n>" : "\<PageDown>"
inoremap <expr> <PageUp>   pumvisible() ? "\<PageUp>\<C-p>\<C-n>" : "\<PageUp>"
" breaks arrow keys
inoremap <expr> <Esc>         pumvisible() ? "\<C-e>" : "\<Esc>"
inoremap <Esc><Esc> <Esc><Esc>

map ; :
nnoremap q; q;

nnoremap <esc> :noh<return><esc>
nnoremap <Esc><Esc> <Esc><Esc>

" hide highlight on enter
nnoremap <silent> <CR> :noh<CR><CR>
nnoremap <Leader>e :e <C-R>=expand('%:p:.:h') . '/'<CR>



" fixes arrow keys
set timeout ttimeoutlen=50 timeoutlen=100

set completeopt=longest,menu

" sessionman.vim
ca SO  SessionOpen
ca SOL SessionOpenLast
ca SC  SessionClose
ca SS  SessionSave
ca SSA SessionSaveAs
ca SSL SessionShowLast
ca SL  SessionList

cabbr <expr> %% expand('%:p:.:h')
cabbr <expr> /// expand('%:p:.:h')

function! ToggleCcH(oses)
  let extension=expand('%:e')
  let filename=expand('%:r')

  let candidate_stems=[filename]
  for os in a:oses
    let idx=match(filename, os.'$')
    if idx >= 0

    endif
  endfor

  let candidates=[]
endfunction

map <F4> :call ToggleCcH(['r'])

let g:sessionman_save_on_exit = 1

function! HighlightTooLongLines()
  highlight def link RightMargin Error
  if &textwidth != 0
    exec ('match RightMargin /\%<' . (&textwidth + 6) . 'v.\%>' . (&textwidth + 1) . 'v/')
  endif
endfunction

augroup filetype
  au! BufRead,BufNewFile *.gyp    setl filetype=python expandtab tabstop=2
  au! BufRead,BufNewFile *.gypi   setl filetype=python expandtab tabstop=2
  au! BufRead,BufNewFile DEPS     setl filetype=python expandtab tabstop=2
augroup END

augroup filetypedetect
  au WinEnter,BufNewFile,BufRead * call HighlightTooLongLines()
augroup END

highlight def link TrailingWhitespace Error
augroup filetypedetect
  autocmd WinEnter,BufNewFile,BufRead * 2match TrailingWhitespace /\s\+$/
augroup End
" disable/enable on enter/leave of insert mode
" autocmd InsertEnter * 2match none
" autocmd InsertLeave * 2match TrailingWhitespace /\s\+$/

hi StatusLine ctermfg=Blue
hi StatusLineNC ctermfg=Red
set laststatus=2

" Tell vim to remember certain things when we exit
"  '10  :  marks will be remembered for up to 10 previously edited files
"  "100 :  will save up to 100 lines for each register
"  :20  :  up to 20 lines of command-line history will be remembered
"  %    :  saves and restores the buffer list
"  n... :  where to save the viminfo files
set viminfo='10,\"100,:20,%,n~/.viminfo

" Main function that restores the cursor position and its autocmd so
" that it gets triggered:
function! ResCur()
  if line("'\"") <= line("$")
    normal! g`"
    return 1
  endif
endfunction

augroup resCur
  autocmd!
  autocmd BufWinEnter * call ResCur()
augroup END

" Setup tab names
" See http://vim.wikia.com/wiki/Show_tab_number_in_your_tab_line
set showtabline=2
" set up tab labels with tab number, buffer name, number of windows

function! SetMyTabLineColors()
  hi TabLineXDirty term=reverse,underline cterm=bold,underline ctermfg=7 ctermbg=1 guifg=White guibg=Red
  hi TabLineXDirtySel term=reverse cterm=bold ctermfg=7 ctermbg=1 guifg=White guibg=Red
endfunction

autocmd! ColorScheme * call SetMyTabLineColors()

hi link TabLineXClean TabLine
hi link TabLineXCleanSel TabLineSel
hi link TabLineXSel TabLineSel
hi link TabLineXFill TabLineFill

set tabline=%!MyTabLine()
function! MyTabLine()
  let s = ''
  for t in range(tabpagenr('$'))
    let tab = t + 1
    " select the highlighting for the buffer names

    " set the tab page number (for mouse clicks)
    let s .= '%' . tab . 'T'

    " get buffer names and statuses
    let buflist = tabpagebuflist(tab)
    let winnr = tabpagewinnr(tab)
    let b = buflist[winnr - 1]
    let n = pathshorten(fnamemodify(bufname(b), ':t'))

    let s .= '%#TabLineX'
    let s .= getbufvar(b, "&modified") ? 'Dirty' : 'Clean'
    let s .= tab == tabpagenr() ? 'Sel' : ''
    let s .= '#'

    " set page number string
    let s .= tab . ':'

    let s.= ' '
    " add buffer names
    if n == ''
      let s .= '[No Name]'
    else
      let s .= n
    endif
    " switch to no underlining and add final space to buffer list
    let s .= '%#TabLineXSel#' . ' '
    " let s .= ' '
  endfor
  " after the last tab fill with TabLineFill and reset tab page nr
  let s .= '%T%#TabLineXFill#%T'
  return s
endfunction


" Auto-install Vundle and install bundles
let vimHadVundle=1
let vundle_readme=expand('~/.vim/bundle/vundle/README.md')
if !filereadable(vundle_readme)
  echo "Installing Vundle.."
  echo ""
  silent !mkdir -p ~/.vim/bundle
  silent !git clone https://github.com/gmarik/vundle ~/.vim/bundle/vundle
  let vimHadVundle=0
endif
set rtp+=~/.vim/bundle/vundle
call vundle#rc()
Bundle 'gmarik/vundle'

let g:vundle_default_git_proto="git"

" Bundles go here
"
" original repos on github
" Bundle 'tpope/vim-fugitive'
" Bundle 'rstacruz/sparkup', {'rtp': 'vim/'}
" vim-scripts repos
" Bundle 'L9'
" Bundle 'FuzzyFinder'
" non github repos
" Bundle 'git://git.wincent.com/command-t.git'

Bundle 'sessionman.vim'
Bundle 'cream-showinvisibles'

" Bundle 'derekwyatt/vim-scala'

Bundle 'felixhummel/setcolors.vim'

Bundle 'cjhopman/FormatComment.vim'
map gqc :call FormatComment()<CR>

if vimHadVundle == 0
  echo "Installing Bundles -- ignore errors"
  echo ""
  :BundleInstall
endif

function! GitVimEx(file, lineno)
  let filecontents = readfile(a:file)
  let loc = split(filecontents[a:lineno - 1])
  let file = loc[1]
  let lineno = loc[2]
  exec 'tabe ' . file
  exec lineno
endfunction

command! -nargs=1 GitVim call GitVimEx('/tmp/git.final', <args>)
command! -nargs=1 GgVim call GitVimEx('/tmp/gg.final', <args>)
cabbr gitvim GitVim
cabbr ggvim GgVim

function! GgGitVimThisLine(close_buffer)
  let dirline=search('^[0-9 	]\+\~', 'bn')
  let line=split(getline('.'), '[\t :]\+') + ['1', '1', '1']
  let file=line[1]
  let lineno=line[2]
  let dir='.'
  if (dirline != 0)
    let dir=substitute(getline(dirline), '[^~]*\~', '', '')
  endif
  let file = dir . '/' . file
  echo file
  if (filereadable(file))
    if (a:close_buffer)
      :q
    endif
    exec 'tabe ' . file
    exec lineno
  endif
endfunction

let s:_ = ''
function! s:ExecuteInShell(command, bang)
  let cmd = a:bang != '' ? '' : a:command == '' ? '' : join(map(split(a:command), 'expand(v:val)')) . ' | _decolorize'

  if (cmd != '')
    let s:_ = cmd
    let bufnr = bufnr('%')
    let winnr = bufwinnr('^' . cmd . '$')
    silent! execute  winnr < 0 ? 'botright new ' . fnameescape(cmd) : winnr . 'wincmd w'
    setlocal buftype=nowrite bufhidden=wipe nobuflisted noswapfile nowrap number
    "silent! :%d
    let message = 'Execute ' . cmd . '...'
    "call append(0, message)
    echo message
    "silent! 2d | resize 1 | redraw
    silent! execute 'silent! %!'. cmd
    silent! execute 'resize ' . line('$')
    silent! execute 'syntax on'
    silent! execute 'autocmd BufUnload <buffer> execute bufwinnr(' . bufnr . ') . ''wincmd w'''
    silent! execute 'autocmd BufEnter <buffer> execute ''resize '' .  line(''$'')'
    silent! execute 'nnoremap <silent> <buffer> <LocalLeader>r :call <SID>ExecuteInShell(''' . cmd . ''', '''')<CR>'
    silent! execute 'nnoremap <silent> <buffer> <LocalLeader>g :execute bufwinnr(' . bufnr . ') . ''wincmd w''<CR>'
    nnoremap <silent> <buffer> <C-W>_ :execute 'resize ' . line('$')<CR>
    "silent! syntax on
  endif
endfunction

map <F6> :call GgGitVimThisLine(1)<CR>
map <F7> :call GgGitVimThisLine(0)<CR>

command! -complete=shellcmd -nargs=+ -bang Shell call s:ExecuteInShell(<q-args>, '<bang>')
cabbrev shell Shell

cabbrev gls Shell gls
cabbrev glsc Shell glsc
cabbrev glsg Shell glsg
cabbrev glsj Shell glsj

cabbrev gg Shell gg
cabbrev ggc Shell ggc
cabbrev ggg Shell ggg
cabbrev ggj Shell ggj

cabbrev gitls Shell gitls
cabbrev gitlsc Shell gitlsc
cabbrev gitlsg Shell gitlsg
cabbrev gitlsj Shell gitlsj

cabbrev gitg Shell gitg
cabbrev gitgc Shell gitgc
cabbrev gitgg Shell gitgg
cabbrev gitgj Shell gitgj
