# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=10000
SAVEHIST=10000
bindkey -e

# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename "$HOME/.zshrc"

autoload -Uz compinit
compinit

# End of lines added by compinstall
function set_prompt(){
    PROMPT='%F{green}%n%f %F{yellow}%1~%f %# '
}
set_prompt

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi

# set PATH so it includes tmux_sessions
if [ -d "$HOME/bin/tmux_sessions" ] ; then
    PATH="$HOME/bin/tmux_sessions:$PATH"
fi


# Switch prompt
function sp(){
    if [ "$PROMPT" != '> ' ]; then
        PROMPT='> ';
    else
        set_prompt
    fi
}

#Persistent rehash
zstyle ':completion:*' rehash true


########### START Exports #############
export EDITOR="vim"
export MANPATH="$HOME/bin/prefix/radare2/share/man:$MANPATH"
export PYTHONSTARTUP=~/.pythonrc
########### END Exports   #############


########### START Aliases #############
## Cmd aliases ##
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias vi='vim'
alias v='vim'
alias i='ipython'
alias p='python'
alias sl="ls"
alias xs="cd"
alias wgcc64='x86_64-w64-mingw32-gcc'
alias wgcc32='i686-w64-mingw32-gcc'
alias cl="clear"
alias tm="tmux"
alias tmn="tmux new -s"
alias tl="tmux list-sessions"
alias ta="tmux attach-session -t"

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias dir='dir --color=auto'
    alias vdir='vdir --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi
########### END Aliases   #############

[ -f /usr/share/fzf/key-bindings.zsh ] && source /usr/share/fzf/key-bindings.zsh
[ -f /usr/share/fzf/completion.zsh ] && source /usr/share/fzf/completion.zsh
 
if [ -d "$HOME/.fzf" ] ; then
    PATH="$PATH:$HOME/.fzf"
fi

# fe - fuzzy-select file to edit
fe() {
  local files
  IFS=$'\n' files=($(fzf-tmux --query="$1" --multi --select-1 --exit-0))
  CMD="[[ -n '$files' ]] && ${EDITOR:-vim} '${files[@]}'"
  print -s "$CMD" && eval "$CMD"
}
bindkey -s '^p' "fe^M"
 
# fd - cd to selected directory
fd() {
  local dir
  dir=$(find ${1:-.} -type d 2> /dev/null | fzf +m) && cd "$dir"
}
 
# fh - fuzzy history search
fh() {
  print -z $(LC_CTYPE=C sort -u $HOME/.histfile | fzf +s --tac )
}
 
tmwin2file(){
  FILE=$(echo $1 | cut -d ':' -f 1)
  LINE=$(echo $1 | cut -d ':' -f 2)

  tmux new-window "vim '+call cursor($LINE, 1)' '$FILE'"
}

tmwin2filestdin(){
  tmwin2file $(head -n 1)
}

# fr - search files by content
fr(){
  # Run Fzf + ripgrep backend
  RG_PREFIX="rg --column --line-number --no-heading --color=always --smart-case "
  RESULT=$(fzf --tac --no-sort --ansi --phony --delimiter ":"  \
    --preview="~/.vim/plugged/fzf.vim/bin/preview.sh {}" \
    --preview-window "+{2}-15"                              \
    --bind "change:reload($RG_PREFIX {q} || true)"       \
    --bind "enter:execute(echo {} | zsh -i -c tmwin2filestdin )"
  )
}
 
alias ff='rg --files | fzf'
 
open_backtrace_entry(){
  tmwin2file $(echo "$1" | sed -n 's/.* \([^ ]*[cxph]:[0-9][0-9]*\)/\1/p')
}
 
lpre(){
  [ -f $1 ] || exit 1
 
  FILTER_CMD="grep '#[0-9]'"
  SED_CMD="sed -n 's/.* \([^ ]*[cxph]:[0-9][0-9]*\)/\1/p'"
 
  cat $1 | eval $FILTER_CMD | fzf --tac --no-sort --ansi --phony \
    --preview="echo {} | $SED_CMD | xargs ~/.vim/plugged/fzf.vim/bin/preview.sh" \
    --bind "enter:execute(zsh -i -c \"open_backtrace_entry {}\")"
}
 
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
