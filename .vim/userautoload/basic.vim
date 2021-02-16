"
" Encoding
"
set encoding=utf-8
set termencoding=utf-8
set fileencodings=utf-8,iso-2022-jp,euc-jp

" Enable setting indent and plugin depending on filetype
filetype indent plugin on

"
" Viewing
"
" Enable syntax highlight 
syntax on
" Show line numbers
set number
" Show rulers
set ruler
" Highlight the current line
set cursorline
" Enable move the cursor to eol
set virtualedit=onemore
" Show the command in the status
set showcmd
" Show the status always
set laststatus=2
" Show the match of brackets
set showmatch
" Bell is visual
" set visualbell
" Disable bell
" set belloff
" For double-byter char
set ambiwidth=double

"
" Cursor
" 
" Smart backspace
set backspace=indent,eol,start
" Enable cursor eol ftom/to bol
set whichwrap=b,s,h,l,<,>,[,],~

"
" Indent
"
" Tab to space
set expandtab
" Indent tab is 2-space
set tabstop=2
" Tab is 2-space
set shiftwidth=2
" Smart tab and indent
set smarttab
set autoindent
set smartindent

"
" Buffer
"
""
set hidden
set confirm
set autoread
set nobackup
set writebackup
set noswapfile

"
" Window
"
" Horizontal split to below by default
set splitbelow
" Vertical split to right by default
set splitright

"
" Search
"
" Highlight the results of search
set hlsearch
" Incremental search
set incsearch
" Delete highlight by Esc-Esc
nnoremap <Esc><Esc> :nohlsearch<CR><ESC>
" Ignore case to search
set ignorecase
" No-ignore case if include upper-case
set smartcase
" Enable re-search from tail to head
set wrapscan

"
" CLI
"
" Command history
set history=10000
" Enable smart command comlementation
set wildmenu
" Yank to clipboard too
set clipboard+=unnamed

"
" Key-Mapping
"
let mapleader = "\<space>"
map <Leader> [fzf-p]
nnoremap <silent> [fzf-p]p     :<C-u>CocCommand fzf-preview.FromResources project_mru git<CR>
nnoremap <silent> [fzf-p]gs    :<C-u>CocCommand fzf-preview.GitStatus<CR>
nnoremap <silent> [fzf-p]ga    :<C-u>CocCommand fzf-preview.GitActions<CR>
nnoremap <silent> [fzf-p]b     :<C-u>CocCommand fzf-preview.Buffers<CR>
nnoremap <silent> [fzf-p]B     :<C-u>CocCommand fzf-preview.AllBuffers<CR>
nnoremap <silent> [fzf-p]o     :<C-u>CocCommand fzf-preview.FromResources buffer project_mru<CR>
nnoremap <silent> [fzf-p]<C-o> :<C-u>CocCommand fzf-preview.Jumps<CR>
nnoremap <silent> [fzf-p]g;    :<C-u>CocCommand fzf-preview.Changes<CR>
nnoremap <silent> [fzf-p]/     :<C-u>CocCommand fzf-preview.Lines --add-fzf-arg=--no-sort --add-fzf-arg=--query="'"<CR>
nnoremap <silent> [fzf-p]*     :<C-u>CocCommand fzf-preview.Lines --add-fzf-arg=--no-sort --add-fzf-arg=--query="'<C-r>=expand('<cword>')<CR>"<CR>
nnoremap          [fzf-p]gr    :<C-u>CocCommand fzf-preview.ProjectGrep<Space>
xnoremap          [fzf-p]gr    "sy:CocCommand   fzf-preview.ProjectGrep<Space>-F<Space>"<C-r>=substitute(substitute(@s, '\n', '', 'g'), '/', '\\/', 'g')<CR>"
nnoremap <silent> [fzf-p]t     :<C-u>CocCommand fzf-preview.BufferTags<CR>
nnoremap <silent> [fzf-p]q     :<C-u>CocCommand fzf-preview.QuickFix<CR>
nnoremap <silent> [fzf-p]l     :<C-u>CocCommand fzf-preview.LocationList<CR>

"
" For vim settings
"
if !has('nvim')
  syntax on
  filetype plugin indent on
  set belloff=all
  set cscopeverbose
  set complete-=i
  " set display=lastline,msgsep
  set fillchars=vert:\|,fold\:\\
  set formatoptions=tcqj
  set fsync
  set listchars=tab\:>\ ,trail\:-,nbsp\:+
  set nrformats=bin,hex
  set sessionoptions-=options
  set shortmess=F
  set sidescroll=1
  set tabpagemax=50
  set tags=./tags;,tags
  set ttimeoutlen=50
  set ttyfast
  set viminfo+=!
endif
