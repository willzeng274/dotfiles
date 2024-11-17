

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

eval "$(/opt/homebrew/bin/brew shellenv)"

# ${ZDOTDIR:-~}/.zshrc

# Set the root name of the plugins files (.txt and .zsh) antidote will use.
zsh_plugins=${ZDOTDIR:-~}/.zsh_plugins

# Ensure the .zsh_plugins.txt file exists so you can add plugins.
[[ -f ${zsh_plugins}.txt ]] || touch ${zsh_plugins}.txt

# Lazy-load antidote from its functions directory.
fpath=(~/.antidote/functions $fpath)
autoload -Uz antidote

# Generate a new static file whenever .zsh_plugins.txt is updated.
if [[ ! ${zsh_plugins}.zsh -nt ${zsh_plugins}.txt ]]; then
  antidote bundle <${zsh_plugins}.txt >|${zsh_plugins}.zsh
fi

# Source your static plugins file.
source ${zsh_plugins}.zsh

resume_() {
    folder_name=$(basename "$PWD")
    cp ~/Desktop/resumes/loo/new/resume_general.tex ./resume_"$folder_name".tex
    open .
    osascript -e 'tell application "iTerm2" to tell current window to close the current session'
}

resume() {
    folder_name=$(basename "$PWD")
    cp ~/Desktop/resumes/loo/new/resume_general.tex ./resume_"$folder_name".tex
    nvim resume_"$folder_name".tex
}

rangercd() {
  local IFS=$'\t\n'
  local tempfile=$(mktemp -t tmp.XXXXXX)
  local ranger_cmd=(
    command
    ranger
    --cmd="map Q chain shell echo %d > \"$tempfile\"; quitall"
  )

  "${ranger_cmd[@]}" "$@"
  if [[ -f "$tempfile" ]] && [[ "$(cat -- "$tempfile")" != "$(pwd)" ]]; then
    cd -- "$(cat "$tempfile")" || return
  fi
  command rm -f -- "$tempfile" 2>/dev/null
}

alias ranger="rangercd"

useless() {
    echo "mvf mvp venv cpy mkdircd pastefile resume resume_ rangercd watch_resume termpdf"
    echo "howdoi eza ranger htop btop tty-clock bat delta fuck tldr"
    echo "dotacat lolcat sl hollywood cowsay cowthink fortune asciiquarium cmatrix nethack chara say ponysay starwars aafire rig cbonsai cava gti"
    echo "cowsay -f"
}

mvf() {
    mkdir -p /tmp/zsh-move-file
    mv "$1" /tmp/zsh-move-file/ && echo "File moved to /tmp/zsh-move-file/$1. Navigate and run mvp"
}

mvp() {
    mv /tmp/zsh-move-file/"$1" ./
    rm /tmp/zsh-move-file/"$1"
}

starwars() {
    telnet towel.blinkenlights.nl
}

venv() {
    source venv/bin/activate
}

# useless but in case I forget pbcopy exists
cpy() {
    xargs | pbcopy
}

mkdircd() {
    mkdir -p "$1" && cd $1
}

pastefile() {
  if [[ -z "$1" ]]; then
    echo "Please provide a filename."
    return 1
  fi
  pbpaste > "$1"
  echo "Clipboard content saved to $1"
}

# ---- FZF -----

# Set up fzf key bindings and fuzzy completion
eval "$(fzf --zsh)"

# Documentation for FZF:
# <C-T> for files
# <C-C> to exit fzf
# <C-R> for recent commands
# **<Tab> to use fzf on most commands for parameters, except git
# git documentation is on their github

# --- setup fzf theme ---
fg="#CBE0F0"
bg="#011628"
bg_highlight="#143652"
purple="#B388FF"
blue="#06BCE4"
cyan="#2CF9ED"

export FZF_DEFAULT_OPTS="--color=fg:${fg},bg:${bg},hl:${purple},fg+:${fg},bg+:${bg_highlight},hl+:${purple},info:${blue},prompt:${cyan},pointer:${cyan},marker:${cyan},spinner:${cyan},header:${cyan}"

# -- Use fd instead of fzf --

export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"

# Use fd (https://github.com/sharkdp/fd) for listing path candidates.
# - The first argument to the function ($1) is the base path to start traversal
# - See the source code (completion.{bash,zsh}) for the details.
_fzf_compgen_path() {
  fd --hidden --exclude .git . "$1"
}

# Use fd to generate the list for directory completion
_fzf_compgen_dir() {
  fd --type=d --hidden --exclude .git . "$1"
}

source ~/fzf-git.sh/fzf-git.sh

show_file_or_dir_preview="if [ -d {} ]; then eza --tree --color=always {} | head -200; else bat -n --color=always --line-range :500 {}; fi"

export FZF_CTRL_T_OPTS="--preview '$show_file_or_dir_preview'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"

# Advanced customization of fzf options via _fzf_comprun function
# - The first argument to the function is the name of the command.
# - You should make sure to pass the rest of the arguments to fzf.
_fzf_comprun() {
  local command=$1
  shift

  case "$command" in
    cd)           fzf --preview 'eza --tree --color=always {} | head -200' "$@" ;;
    export|unset) fzf --preview "eval 'echo \${}'"         "$@" ;;
    ssh)          fzf --preview 'dig {}'                   "$@" ;;
    *)            fzf --preview "$show_file_or_dir_preview" "$@" ;;
  esac
}

# bun completions
[ -s "/Users/user/.bun/_bun" ] && source "/Users/user/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

eval "$(zoxide init zsh)"
export PATH="/opt/homebrew/opt/gcc/bin:$PATH"
export PATH="/opt/homebrew/opt/ruby/bin:$PATH"
export PATH="$HOME/.gem/bin:$PATH"
export PATH="$HOME/flutter/bin:$PATH"
export EDITOR=nvim
export CXXFLAGS="-std=c++11"
export GPG_TTY=$TTY

alias skim='/Applications/Skim.app/Contents/MacOS/Skim'
alias termpdf="python /Users/user/Desktop/Projects/termpdf.py/termpdf.py"
alias ls="eza --color=always --long --git --no-filesize --icons=always --no-time --no-user --no-permissions"

watch_resume() {
    local file="$1"

    # If no argument is passed, check the current directory for PDF files
    if [[ -z "$file" ]]; then
        # Find PDF files in the current directory (non-recursive)
        pdf_files=($(ls *.pdf 2>/dev/null))

        # If no PDF files are found, show a usage message
        if (( ${#pdf_files[@]} == 0 )); then
            echo "No PDF files found in the current directory."
            return 1
            # If more than 1 PDF file is found, show a usage message
        elif (( ${#pdf_files[@]} > 1 )); then
            echo "More than 1 PDF file found. Please specify the file."
            return 1
        else
            # If exactly 1 PDF file is found, use it as the default file
            # echo "${pdf_files}"
            file="${pdf_files}"
        fi
    fi

    # If we get here, `file` is set to the selected PDF file.
    # echo "Using file: $file"
    while true; do
        echo "$file" | entr -d python /Users/user/Desktop/Projects/termpdf.py/termpdf.py "$file"
    done
}

eval $(thefuck --alias)

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/opt/anaconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/opt/anaconda3/etc/profile.d/conda.sh" ]; then
        . "/opt/anaconda3/etc/profile.d/conda.sh"
    else
        export PATH="/opt/anaconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<



