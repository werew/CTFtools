
" In many terminal emulators the mouse works just fine.  By enabling it you
" can position the cursor, Visually select and scroll with the mouse.
"if has('mouse')
"  set mouse=a
"endif


" Identation Options
set autoindent 		        " New lines inherit the indentation of previous lines.
set expandtab               " Convert tabs to spaces.
filetype plugin indent on   " Enable indentation rules that are file-type specific.
set shiftround 	            " When shifting lines, round the indentation to the nearest multiple of “shiftwidth.”
set shiftwidth=4            " When shifting, indent using four spaces.
set smarttab                " Insert “tabstop” number of spaces when the “tab” key is pressed.
set tabstop=4               " Indent using four spaces.


" Search Options
set hlsearch                " Enable search highlighting.
set ignorecase 	            " Ignore case when searching.
set incsearch               " Incremental search that shows partial matches.
set smartcase               " Automatically switch search to case-sensitive when search query contains an uppercase letter.


" Rendering Options
set display+=lastline       " Always try to show a paragraph’s last line.
set encoding=utf-8          " Use an encoding that supports unicode.
set linebreak               " Avoid wrapping a line in the middle of a word.
set scrolloff=1             " The number of screen lines to keep above and below the cursor.
set sidescrolloff=5         " The number of screen columns to keep to the left and right of the cursor.
syntax enable               " Enable syntax highlighting.
set wrap                    " Enable line wrapping.
set display=truncate        " Show @@@ in the last line if it is truncated.


" UI Options
set background=light        " Use colors that suit a light background
set ruler		            " Show the cursor position all the time
set wildmenu		        " Display completion matches in a status line
set title                   " Set the window’s title, reflecting the file currently being edited


" Miscellaneous Options     
set history=200		        " Keep 200 lines of command line history
set showcmd		            " Display incomplete commands
set ttimeout		        " Time out for key codes
set ttimeoutlen=100	        " Wait up to 100ms after Esc for special key


" Plugins
let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.vim/plugged')
    " Plugin outside ~/.vim/plugged with post-update hook
    Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': 'yes \| ./install' }
    Plug 'junegunn/fzf.vim'
call plug#end()


" Function to run Fuzzy Finder from within vim
function! RipgrepFzf(query, fullscreen)
  let command_fmt = 'rg --column --line-number --no-heading --color=always --smart-case %s || true'
  let initial_command = printf(command_fmt, shellescape(a:query))
  let reload_command = printf(command_fmt, '{q}')
  let spec = {'options': ['--phony', '--query', a:query, '--bind', 'change:reload:'.reload_command]}
  call fzf#vim#grep(initial_command, 1, fzf#vim#with_preview(spec), a:fullscreen)
endfunction

" Function to run Fuzzy Finder from within vim using the word under cursor
function! RipgrepFzfCurrentWord(fullscrean)
  let current_word = expand('<cword>')
  call RipgrepFzf(current_word, a:fullscrean)
endfunction

" Create Fr command to run FzF from vim
command! -nargs=* -bang Fr call RipgrepFzf(<q-args>, <bang>0)

" Create Frcw command to run FzF from vim using the word under cursor
command! -nargs=* -bang Frcw call RipgrepFzfCurrentWord(<bang>0)

" Bind Frcw command to Ctrl-G
nnoremap <C-g> :Frcw <Cr>
