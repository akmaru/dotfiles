" Required:
let s:cache_home=empty($XDG_CACHE_HOME) ? expand('$HOME/.cache') : $XDG_CACHE_HOME
let s:dein_dir = s:cache_home . '/dein'
let s:dein_github = s:dein_dir . '/repos/github.com'
let s:dein_repo_name = 'Shougo/dein.vim'
let s:dein_repo_dir = s:dein_github . '/' . s:dein_repo_name

" Check dein has been installed or not.
if !isdirectory(s:dein_repo_dir)
  let s:git = system("which git")
  if strlen(s:git) != 0
    echo 'dein is not installed, install now '
    let s:dein_repo = 'https://github.com/' . s:dein_repo_name
    echo 'git clone ' . s:dein_repo . ' ' . s:dein_repo_dir
    call system('git clone ' . s:dein_repo . ' ' . s:dein_repo_dir)
  endif
endif

set runtimepath+=~/.cache/dein/repos/github.com/Shougo/dein.vim

" Required:
if dein#load_state(s:dein_dir)
  let g:dein#cache_directory = s:dein_dir

  call dein#begin(s:dein_dir)

  " Let dein manage dein
  " Required:
  call dein#add('$HOME/.cache/dein/repos/github.com/Shougo/dein.vim')

  " Let toml settings
  let s:toml_dir = $HOME . '/.vim/userautoload/dein' 
  let s:toml     = s:toml_dir . '/plugins.toml'
  let s:lazy     = s:toml_dir . '/lazy.toml'

  call dein#load_toml(s:toml, {'lazy': 0})
  call dein#load_toml(s:lazy, {'lazy': 1})
  
  " Add or remove your plugins here like this:
  "call dein#add('Shougo/neosnippet.vim')
  "call dein#add('Shougo/neosnippet-snippets')

  " Required:
  call dein#end()
  call dein#save_state()
endif

" Required:
" filetype plugin indent on
" syntax enable

" If you want to install not installed plugins on startup.
if dein#check_install()
  call dein#install()
endif
