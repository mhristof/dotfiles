set nocompatible              " be iMproved, required
filetype off                  " required

" initial checkout
"    git clone https://github.com/gmarik/Vundle.vim.git ~/.vim/bundle/Vundle.vim
" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'gmarik/Vundle.vim.git'

Plugin 'MarcWeber/vim-addon-mw-utils.git'
Plugin 'ekalinin/Dockerfile.vim'
Plugin 'elzr/vim-json'
Plugin 'fatih/vim-go'
Plugin 'godlygeek/tabular'
Plugin 'hashivim/vim-terraform.git'
Plugin 'hynek/vim-python-pep8-indent'
Plugin 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plugin 'junegunn/fzf.vim'
Plugin 'mhristof/vim-snipmate.git'
Plugin 'mhristof/vim-template.git'
Plugin 'mileszs/ack.vim.git'
Plugin 'ngmy/vim-rubocop'
Plugin 'serialdoom/VisIncr.git'
Plugin 'serialdoom/comments.vim.git'
Plugin 'serialdoom/vcscommand.vim.git'
Plugin 'serialdoom/vim-ansible-yaml.git'
Plugin 'tomasr/molokai.git'
Plugin 'tommcdo/vim-lion'
Plugin 'tomtom/tlib_vim.git'
Plugin 'tpope/vim-commentary.git'
Plugin 'tpope/vim-fugitive'
Plugin 'tpope/vim-obsession'
Plugin 'tpope/vim-surround'
Plugin 'vim-scripts/DirDiff.vim.git'
Plugin 'vim-scripts/DrawIt'
Plugin 'w0rp/ale'
Plugin 'zimbatm/haproxy.vim'
Plugin 'benwainwright/fzf-project'


" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required
" To ignore plugin indent changes, instead use:
"filetype plugin on
"
" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
"  Instal all with
"  	vim +PluginInstall +qall
"
" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line

let s:uname = system("uname -s")
let mapleader = ","
set t_Co=256
set bg=dark
set hidden
set ff=unix
set showmatch
set ignorecase
set nocompatible
set nowrap
set history=9999
inoremap j<space> <esc>
set modeline
set ls=2
set so=999 " center the window
set sw=4
set incsearch
set modeline
set viminfo='10,\"100,:20,% " what to save for each file
set wrap " wrap the damn lines
set lbr "wrap at character
set breakat=\ ,(*;+=/| " set your on line break charactesr
if filereadable(glob('~/.vim/bundle/vim-fugitive/plugin/fugitive.vim'))
    set statusline=%{fugitive#statusline()}%<%f%h%m%r:%l%=\ %P
endif
set backspace=indent,eol,start " backspace now moves to previous line 
set hlsearch
set autoindent
syntax enable
set wildignore +=*.d,*.o,*.dox,*.a,*.clean,*.bin,*.elf,*.i,*.back
set expandtab "use spaces instead of tabs
set tabstop=4
set shiftwidth=4
set clipboard=unnamed
set wildignorecase
set smartindent
set sessionoptions+=localoptions
set statusline+=%#warningmsg#
set statusline+=%*

let VCSCommandVCSTypePreference='git'
let g:CommandTMaxCachedDirectories=0
let g:DirDiffExcludes = "*.pyc"
let g:VCSCommandDeleteOnHide=66
let g:ackprg = 'ag --nogroup --nocolor --column'
let g:ale_dockerfile_hadolint_use_docker  = "always"
let g:ale_lint_on_text_changed = 'never'
let g:ale_linters = {'python': ['pycodestyle', 'pylint', 'pydocstyle'],}
let g:fzfSwitchProjectAlwaysChooseFile = 0
let g:fzfSwitchProjectWorkspaces = [ '~/code']
let g:fzf_layout = { 'down': '40%' } " disable the weird center pop up window
let g:go_fmt_command = "goimports"
let g:lion_squeeze_spaces = 1
let g:netrw_banner = 0
let g:netrw_browse_split = 0
let g:netrw_liststyle = 3
let g:netrw_sort_sequence = '[\/]$,\<core\%(\.\d\+\)\=\>,\.h$,\.c$,\.cpp$,\~\=\*$,*,\.o$,\.obj$,\.info$,\.swp$,\.bak$,\.clean$,\.rej,\.orig,\~$'
let g:terraform_fmt_on_save=1



map <C-j> <C-W>j
map <C-k> <C-W>k
map <C-h> <C-W>h
map <C-l> <C-W>l
map Q <Nop>
" delete text without entering the registers. Usefull when you what to replace
" something
nmap X "_d
nmap XX "_dd
nmap t :FZF<cr>
nmap ed :e %:h<cr>
nmap <Space> <PageDown>
nmap + :ts <C-R>=expand("<cword>")<cr><cr>
nmap <leader>n :cnext<cr>
nmap <leader>m :cprev<cr>
nmap <leader>b :Gbrowse<cr>
nmap <leader>t :FzfSwitchProject<cr>
nmap <C-]> :call TagsOrAck()<cr>
if s:uname == "Darwin\n"
    map `r :History:<cr>
    map `b :Buffers<cr>
    map `a :Ag<cr>
    map `e :GBrowse<cr>
endif



vmap X "_d
vmap x "_d

cnoremap mk. !mkdir -p <c-r>=expand("%:h")<cr>/

if filereadable(glob('~/.vim/bundle/molokai/colors/molokai.vim'))
  colorscheme molokai
endif
set cursorline
set cursorcolumn
hi CursorLine   cterm=NONE ctermbg=232 guibg=#050505
hi CursorColumn cterm=NONE ctermbg=232 guibg=#050505
hi Folded ctermbg=234 ctermfg=red
hi ColorColumn ctermbg=256
hi Search ctermbg=134 ctermfg=0
hi clear SpellBad
hi SpellBad term=standout ctermfg=1 term=underline cterm=underline
hi clear SpellCap
hi SpellCap term=underline cterm=underline
hi clear SpellRare
hi SpellRare term=underline cterm=underline
hi clear SpellLocal
hi SpellLocal term=underline cterm=underline


if has("autocmd")
    autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
    autocmd WinEnter * setlocal cursorline
    autocmd WinEnter * setlocal cursorcolumn
    autocmd WinEnter * setlocal cc=80
    autocmd WinLeave * setlocal nocursorline
    autocmd WinLeave * setlocal nocursorcolumn
    autocmd WinLeave * setlocal cc=0
    autocmd FileType python :set makeprg=pep8\ %
    autocmd BufReadPost,WinEnter *.py :set makeprg=pep8\ %
    autocmd BufEnter *.mkf :set ft=make
    autocmd BufEnter *.dsl :set ft=groovy
    autocmd BufEnter Jenkinsfile :set ft=groovy
    autocmd BufEnter Jenkinsfile :setlocal shiftwidth=2 tabstop=2
    autocmd BufEnter *.yml :set ft=ansible
    autocmd BufEnter haproxy.cfg* :set ft=haproxy
    autocmd BufEnter .travis.yml :set ft=yaml
    autocmd WinLeave * :setlocal rnu!
    autocmd WinEnter * :setlocal rnu
    autocmd WinEnter,BufEnter Vagrantfile,*.rb,*.erb call SetupRuby()
    autocmd FileType ruby,eruby call SetupRuby()
    autocmd VimResized * wincmd =
    autocmd BufWrite * :diffupdate
    autocmd WinEnter,BufWritePost *.py call PythonCtags()
    autocmd WinEnter,BufWritePost *.tf call TerraformCtags()
    autocmd FileType markdown set makeprg=grip\ -b\ %\ &>\ /dev/null
    autocmd VimEnter * call SetupObsession()
    autocmd FileType terraform :nnoremap K :call TerraformMan()<CR>
    autocmd FileType yaml :nnoremap K :call AnsibleMan()<CR>
    autocmd BufEnter *.github/workflows/*.yml :set ft=github-actions
    autocmd FileType github-actions call SetupGithubActions()
    autocmd filetype netrw nnoremap <buffer> t :FZF<cr><cr>
endif

function PythonCtags()
    let pyctags = job_start(["ctags", "-R", "--fields=+l", "--languages=python", "--python-kinds=-iv", "."])
endfunction

function TerraformCtags()
    let tfctags = job_start(["ctags", "-R", "--languages=terraform", "."])
endfunction

if has("user_commands")
    command! -bang -nargs=? -complete=file E e<bang> <args>
    command! -bang -nargs=? Cs cs<bang> <args>
    command! -bang -nargs=? -complete=file W w<bang> <args>
    command! -bang -nargs=? -complete=file Wq wq<bang> <args>
    command! -bang -nargs=? -complete=file WQ wq<bang> <args>
    command! -bang -nargs=? -complete=file Vs vs<bang> <args>
    command! -bang -nargs=? -complete=file VS vs<bang> <args>
    command! -bang -nargs=? -complete=file E e<bang> <args>
    cabbrev Set set
    cabbrev ack Ack
    cabbrev ag Ag
    cabbrev Call call
    cabbrev bb :call GitBrowse()<cr>
    " map the damn :W so that you dont type it twice. Or even 3 times. Fucking noob.
    command! -bang Wqa wqa<bang>
    command! -bang Wa wa<bang>
    command! -bang WA wa<bang>
    command! -bang Q q<bang>
    command! -bang QA qa<bang>
    command! -bang Qa qa<bang>
    command! -bang Set set<bang>
    command! -bang Vs vs<bang>
endif

function! SetupRuby()
    setlocal tabstop=2
    setlocal shiftwidth=2
    setlocal cc=100
    setlocal nocursorline
    setlocal nocursorcolumn
    setlocal nornu
endfunction

function TagsOrAck()
    let l:word = expand('<cword>')
    try
        exe ":tag " l:word
    catch
        exe ":Ag! " l:word
    endtry
endfunction

function Snippets()
    exe ":vsplit ~/.vim/bundle/vim-snipmate/snippets/" . &filetype . ".snippets"
endfunction

function SetupObsession()
    if argc() != 0
        " vim invoked with args, so dont try to restore session
        return
    endif

    let l:file = $HOME . "/.vim/sessions/"  . substitute(getcwd(), "/", "-", "g")
    if filereadable(l:file)
        execute "silent! source " . l:file
    endif

    execute "silent! mkdir -p ~/.vim/sessions/"
    execute ":silent! Obsession " . l:file
endfunction

if filereadable(expand("~/.vimrc.local"))
    source ~/.vimrc.local
endif

function Jq()
    execute ":%!jq '.'"
endfunction

function Rl()
    echo expand('%:p')
endfunction

function TerraformMan()
    let line=getline('.')
    exec "silent !~/bin/man-terraform.sh " . line
    exec ":redraw!"
endfunction

function AnsibleMan()
    let save_pos = getpos(".")
    normal $
    normal mi
    normal {
    normal y'i
    call setpos('.', save_pos)

    execute "silent !pbpaste | ~/bin/man-ansible.sh"
    exec ":redraw!"
endfunction

function SetupGithubActions()
    setlocal syntax=yaml
endfunction

function GitBrowse()
    let line=line(".") + 1
    exec "silent !open $(gitbrowse " . expand('%') . " --line " . line . ")"
    exec ":redraw!"
endfunction
