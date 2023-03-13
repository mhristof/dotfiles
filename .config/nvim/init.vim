set nocompatible               " be improved, required
filetype off                   " required
" set the runtime path to include Vundle and initialize
set rtp+=~/.config/nvim/bundle/Vundle.vim
call vundle#begin()            " required
Plugin 'VundleVim/Vundle.vim'  " required

" ===================
" my plugins here
" ===================

Plugin 'MarcWeber/vim-addon-mw-utils.git'
Plugin 'benwainwright/fzf-project'
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
Plugin 'serialdoom/VisIncr.git'
Plugin 'serialdoom/comments.vim.git'
Plugin 'serialdoom/vcscommand.vim.git'
Plugin 'skywind3000/asyncrun.vim'
Plugin 'tomasr/molokai.git'
Plugin 'tommcdo/vim-lion'
Plugin 'tomtom/tlib_vim.git'
Plugin 'tpope/vim-commentary.git'
Plugin 'tpope/vim-fugitive'
Plugin 'tpope/vim-obsession'
Plugin 'tpope/vim-surround'
Plugin 'vim-scripts/DirDiff.vim.git'
Plugin 'w0rp/ale'
Plugin 'zimbatm/haproxy.vim'
Plugin 'mbbill/undotree'
Plugin 'rhadley-recurly/vim-terragrunt'
Plugin 'neoclide/coc.nvim', {'branch': 'release'}

" ===================
" end of plugins
" ===================
call vundle#end()               " required
filetype plugin indent on       " required


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
set mouse=

function SourceIfExists(file)
  if filereadable(expand(a:file))
    exe 'source' a:file
  endif
endfunction


call SourceIfExists("~/.fzf.projects.vim") "let g:fzfSwitchProjectProjects

let VCSCommandVCSTypePreference='git'
let g:CommandTMaxCachedDirectories=0
let g:DirDiffExcludes = "*.pyc"
let g:VCSCommandDeleteOnHide=66
let g:ackprg = 'ag --nogroup --nocolor --column'
let g:ale_dockerfile_hadolint_use_docker  = "yes"
let g:ale_fix_on_save = 1
let g:ale_fixers = {
    \'sh': ['shfmt'],
    \'python': [ 'add_blank_lines_for_python_control_statements', 'autoflake', 'autoimport', 'autopep8', 'black', 'isort', 'pyflyby', 'remove_trailing_lines', 'reorder-python-imports', 'trim_whitespace'],
\}
let g:ale_history_log_output = 1
let g:ale_lint_on_text_changed = 'never'
let g:ale_linters = { 'yaml': ['yamllint', 'prettier'], 'python': ['bandit', 'pycodestyle', 'pylint', 'pydocstyle', 'black'], 'go': ['revive', 'golangci-lint', 'staticcheck'], }
let g:ale_sh_shfmt_options='-i 4 -ci' " Indent with N spaces
let g:fzfSwitchProjectAlwaysChooseFile = 1
let g:fzf_layout = { 'down': '40%' } " disable the weird center pop up window
let g:go_def_mode = "gopls"
let g:go_fmt_command="gopls"
let g:go_gopls_gofumpt=1
let g:lion_squeeze_spaces = 1
let g:netrw_banner = 0
let g:netrw_browse_split = 0
let g:netrw_liststyle = 3
let g:netrw_sort_sequence = '[\/]$,\<core\%(\.\d\+\)\=\>,\.h$,\.c$,\.cpp$,\~\=\*$,*,\.o$,\.obj$,\.info$,\.swp$,\.bak$,\.clean$,\.rej,\.orig,\~$'
let g:terraform_fmt_on_save = 1

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
cnoremap gremote r!git config --get remote.origin.url

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
    autocmd BufEnter *.dsl :set ft=groovy
    "autocmd BufEnter *.yml :set ft=ansible
    autocmd BufEnter .pre-commit-config.yaml :set ft=yaml.pre-commit
    autocmd BufEnter *.github/workflows/*.yml :set ft=yaml.github-actions
    autocmd BufEnter .gitlab-ci.yml :set ft=yaml.gitlab
    autocmd BufEnter .mega-linter.yml :set ft=yaml.megalinter
    autocmd BufEnter *.mkf :set ft=make
    autocmd BufEnter .travis.yml :set ft=yaml
    autocmd BufEnter *.Jenkinsfile,Jenkinsfile :set ft=groovy
    autocmd BufEnter Jenkinsfile :setlocal shiftwidth=2 tabstop=2
    autocmd BufEnter haproxy.cfg* :set ft=haproxy
    autocmd BufRead * if (expand('%:e') =~ "yaml" || expand('%:e') =~ "yml") && search('apiVersion:', 'nw') | setlocal ft=yaml.k8s | endif
    autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
    autocmd BufReadPost,WinEnter *.py :set makeprg=pep8\ %
    autocmd BufWrite * :diffupdate
    autocmd FileType github-actions call SetupGithubActions()
    autocmd FileType markdown set makeprg=grip\ -b\ %\ &>\ /dev/null
    autocmd FileType python :set makeprg=pep8\ %
    autocmd FileType ruby,eruby call SetupRuby()
    autocmd FileType yaml :nnoremap K :call AnsibleMan()<CR>
    autocmd VimEnter * call SetupObsession()
    autocmd VimResized * wincmd =
    autocmd WinEnter * :setlocal rnu
    autocmd WinEnter * setlocal cc=80
    autocmd WinEnter * setlocal cursorcolumn
    autocmd WinEnter * setlocal cursorline
    autocmd WinEnter,BufEnter Vagrantfile,*.rb,*.erb call SetupRuby()
    autocmd WinEnter,BufWritePost *.py call PythonCtags()
    autocmd FileType gitrebase,gitcommit set fo+=t
    autocmd WinLeave * :setlocal rnu!
    autocmd WinLeave * setlocal cc=0
    autocmd WinLeave * setlocal nocursorcolumn
    autocmd WinLeave * setlocal nocursorline
    autocmd filetype gitrebase :nnoremap s :call Squash()<cr>
    autocmd FileType gitrebase,gitcommit set tw=72 fo=cqt wm=0
    autocmd WinEnter,BufEnter *.sh.tpl setlocal ft=bash
    autocmd filetype netrw nnoremap <buffer> t :FZF<cr><cr>
    autocmd BufEnter,VimEnter *.aws/config set filetype=dosini
    autocmd BufEnter,VimEnter Dockerfile map <leader>p :call ApkUnpin()<cr>

    autocmd WinEnter,BufWritePost *.tf call TerraformCtags()

    autocmd FileType terraform :nnoremap K :call TerraformMan()<CR>
    autocmd BufWritePost *.hcl :call TerraformFormat()
    autocmd BufNewFile,BufRead,BufWritePost *.pkr.hcl setlocal filetype=packer syntax=hcl
endif

function TerraformFormat()
    let save_pos = getpos(".")
    exec ":silent! terragrunt hclfmt"
    exec ":e!"
    call setpos(".", save_pos)
endfunction

function PackerFormat()
    let save_pos = getpos(".")
    exec ":silent! packer fmt %"
    call setpos(".", save_pos)
endfunction

function Squash()
    exec ":2,$s/^pick/squash/g"
endfunction

function ApkUnpin()
    exec ".s/==\\S*//g"
endfunction

function PythonCtags()
    exec ":AsyncRun ctags -R --fields=+l --languages=python --python-kinds=-iv ."
endfunction

function TerraformCtags()
    exec ":AsyncRun ctags -R --languages=terraform ."
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
    cabbrev gob Gob
    cabbrev gcmp !bash ~/.zsh.autoload/gcmp
    cabbrev ww :noautocmd w

    cabbrev bb :call GitBrowse()<cr>
    cabbrev oo :call OpenLocalRepo()<cr>
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
    let s:split = "vsplit"
    for s:ft in split(&filetype, '\.')
        exe ":" . s:split . " ~/.vim/bundle/vim-snipmate/snippets/" . s:ft . ".snippets"
        let s:split = "split"
    endfor
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
    let line=line(".")
    exec "silent !open $(gi browse " . expand('%') . " --line " . line . ")"
    exec ":redraw!"
endfunction

function! GitCheckout(branch)
    execute ':silent !git checkout '.a:branch
endfunction
command! Gob call fzf#run({
    \  'source': "git branch --all",
    \  'sink':    function('GitCheckout')})

function OpenLocalRepo()
    let path = system("~/bin/local-repo-from-string.sh '" . getline(search("^ *source = ", "n")) . "'")
    exec ":sp " . path
endfunction

" Use tab for trigger completion with characters ahead and navigate
" NOTE: There's always complete item selected by default, you may want to enable
" no select by `"suggest.noselect": true` in your configuration file
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config
inoremap <silent><expr> <leader><TAB>
      \ coc#pum#visible() ? coc#pum#next(1) :
      \ CheckBackspace() ? "\<Tab>" :
      \ coc#refresh()
inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

" Make <CR> to accept selected completion item or notify coc.nvim to format
" <C-g>u breaks current undo, please make your own choice
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

let g:copilot_filetypes = {'yam': v:true}
