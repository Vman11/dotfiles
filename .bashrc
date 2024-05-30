# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples
alias sbrc='source ~/.bashrc'
# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi


export PYENV_ROOT="$HOME/.pyenv"
if [ -d "$PYENV_ROOT" ]; then
    export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$("$PYENV_ROOT"/bin/pyenv init -)"
    eval "$("$PYENV_ROOT"/bin/pyenv init --path)"
    source "$PYENV_ROOT/completions/pyenv.bash"
    export PYENV_PREFIX
    PYENV_PREFIX=$(pyenv prefix)
fi


CHOSEN_PYTHON_VERSION=3.10.5
deactivate_venv()
{
    # https://stackoverflow.com/questions/85880/determine-if-a-function-exists-in-bash
    if [ -n "$(type -t conda)" ] && [ "$(type -t conda)" = function ]; then
        conda deactivate
    fi
    OLD_VENV=$VIRTUAL_ENV
    echo "deactivate_venv OLD_VENV=$OLD_VENV"
    if [ "$OLD_VENV" != "" ]; then
        if [ -n "$(type -t deactivate)" ] && [ "$(type -t deactivate)" = function ]; then
            # deactivate bash function exists
            deactivate
        fi
    fi
}

workon_py()
{
    __doc__="
    Switch virtual environments
    "
    local NEW_VENV=$1
    echo "workon_py: NEW_VENV = $NEW_VENV"

    if [ ! -f "$NEW_VENV/bin/activate" ]; then
        # Check if it is the name of a conda or virtual env
        # First try conda, then virtualenv
        local TEMP_PATH=$_CONDA_ROOT/envs/$NEW_VENV
        #echo "TEMP_PATH = $TEMP_PATH"
        if [ -d "$TEMP_PATH" ]; then
            NEW_VENV=$TEMP_PATH
        else
            local TEMP_PATH=$HOME/$NEW_VENV
            if [ -d "$TEMP_PATH" ]; then
                local NEW_VENV=$TEMP_PATH
            fi
        fi
    fi
    # Try to find the environment the user requested
    PYENV_ACTIVATE_CAND1=$(echo "$(pyenv root)"/versions/*/envs/"$NEW_VENV"/bin/activate)

    if [ -f "$PYENV_ACTIVATE_CAND1" ]; then
        deactivate_venv
        source "$PYENV_ACTIVATE_CAND1"
    elif [ -d "$NEW_VENV" ]; then
        # Ensure the old env is deactivated
        deactivate_venv
        # shellcheck disable=SC1091
        source "$NEW_VENV/bin/activate"
    fi
}



_AUTOSTART_VENV=1
if [[ "$_AUTOSTART_VENV" == "1" ]]; then
    if [ "$DID_MY_BASHRC_INIT" == "" ]; then
        # For some reason VIRTUAL_ENV is initialized as "", so unset it
        unset VIRTUAL_ENV
        #PYTHON_VERSION_PRIORITY=( "3.12.3" "3.11.2" "3.10.10" "3.10.5" "3.9.9" )
        PYTHON_VENV_PRIORITY=( "3.11.9" "3.11.2" "3.10.10" "3.10.5" "3.9.9" )
        #PYTHON_VERSION_PRIORITY=( "3.10.5" )
        _found_env=0
        for CHOSEN_PYTHON_VERSION in "${PYTHON_VENV_PRIORITY[@]}"; do
            if [ -d "$PYENV_ROOT/versions/$CHOSEN_PYTHON_VERSION/envs/pyenv$CHOSEN_PYTHON_VERSION" ]; then
                _found_env=1
                pyenv shell "$CHOSEN_PYTHON_VERSION"
                source "$PYENV_ROOT/versions/$CHOSEN_PYTHON_VERSION/envs/pyenv$CHOSEN_PYTHON_VERSION/bin/activate" 
                break
            fi
        done
        if [[ "$_found_env" == "0" ]]; then
            #echo $CHOSEN_PYTHON_VERSION
            if [ -d "$HOME/.local/conda/envs/conda38" ]; then
                conda activate conda38
            elif [ -d "$HOME/.local/conda/envs/py38" ]; then
                conda activate py38
            elif [ -d "$HOME/.local/conda/envs/py37" ]; then
                conda activate py37
            elif [ -d "$HOME/.local/conda/envs/py36" ]; then
                conda activate py36
            fi 
        fi

    elif [ "$VIRTUAL_ENV" != "" ]; then
        # On reload use the same venv you were in
        #echo "WORKON VIRTUAL_ENV = $VIRTUAL_ENV"
        workon_py "$VIRTUAL_ENV"
    elif [ "$CONDA_PREFIX" != "" ]; then
        # On reload use the same venv you were in
        #echo "WORKON CONDA_PREFIX = $CONDA_PREFIX"
        workon_py "$CONDA_PREFIX"
    fi

fi
