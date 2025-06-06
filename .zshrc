HISTFILE=~/.zsh_history

HISTSIZE=10000

SAVEHIST=10000

setopt EXTENDED_HISTORY

# --- setup fzf theme - moved here for faster color initialization ---
fg="#CBE0F0"
bg="#011628"
bg_highlight="#143652"
purple="#B388FF"
blue="#06BCE4"
cyan="#2CF9ED"

export FZF_DEFAULT_OPTS="--color=fg:${fg},bg:${bg},hl:${purple},fg+:${fg},bg+:${bg_highlight},hl+:${purple},info:${blue},prompt:${cyan},pointer:${cyan},marker:${cyan},spinner:${cyan},header:${cyan}"

# Set the root name of the plugins files (.txt and .zsh) antidote will use.
zsh_plugins=${ZDOTDIR:-~}/.zsh_plugins

# Ensure the .zsh_plugins.txt file exists so you can add plugins.
[[ -f ${zsh_plugins}.txt ]] || touch ${zsh_plugins}.txt

# Lazy-load antidote from its functions directory.
fpath=(~/.antidote/functions $fpath)
autoload -Uz antidote
autoload -Uz add-zsh-hook
autoload -Uz compinit && compinit

# Generate a new static file whenever .zsh_plugins.txt is updated.
if [[ ! ${zsh_plugins}.zsh -nt ${zsh_plugins}.txt ]]; then
  antidote bundle <${zsh_plugins}.txt >|${zsh_plugins}.zsh
fi

# Source your static plugins file - MOVED BEFORE Powerlevel10k for color initialization
source ${zsh_plugins}.zsh

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"
# ${ZDOTDIR:-~}/.zshrc

AUTO_UPDATE_TAB_TITLE=true

init() {
    if [[ "$AUTO_UPDATE_TAB_TITLE" == true ]]; then
        echo -ne "\033]0;${PWD/#$HOME/~}\a"
    fi
}

add-zsh-hook chpwd init
init

# Defer Homebrew setup if already configured
if ! command -v brew &> /dev/null; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

resume_() {
    folder_name=$(basename "$PWD")
    cp ~/Desktop/resumes/loo/new/resume_general.tex ./resume_"$folder_name".tex
    open .
    osascript -e 'tell application "iTerm2" to tell current window to close the current session'
}

resume() {
    folder_name=$(basename "$PWD")
    target_file="./resume_${folder_name}.tex"

    if [ -f "$target_file" ]; then
        echo "File $target_file already exists. Do you want to overwrite it? (y/n): "
        read choice
        case "$choice" in
            [Yy]* )
                echo "Overwriting file..."
                cp ~/Desktop/resumes/loo/new/resume_general.tex "$target_file"
                nvim "$target_file"
                ;;
            [Nn]* )
                echo "Exiting without making changes."
                return 1
                ;;
            * )
                echo "Invalid input. Exiting."
                return 1
                ;;
        esac
    else
        cp ~/Desktop/resumes/templates/general/resume_general.tex "$target_file"
        nvim "$target_file"
    fi
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

title() {
    if [[ -n "$1" ]]; then
        echo -ne "\033]0;$1\a"
        AUTO_UPDATE_TAB_TITLE=false  # Disable auto-updates
    else
        # If no argument, restore automatic updates and use the current directory
        AUTO_UPDATE_TAB_TITLE=true
        echo -ne "\033]0;${PWD/#$HOME/~}\a"
    fi
}

useless() {
    echo "mvf mvp venv cpy mkdircd pastefile resume resume_ rangercd watch_resume termpdf ff"
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

ff() {
    aerospace list-windows --all | fzf --bind 'enter:execute(bash -c "aerospace focus --window-id {1}")+abort'
}

# useless but in case I forget pbcopy exists
cpy() {
    xargs | pbcopy
}

mkdircd() {
    if [ -d "$1" ]; then
        echo "Directory '$1' already exists."
        cd "$1" || return
    else
        mkdir -p "$1" && cd "$1" || return
    fi
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

# -- Use fd instead of fzf --

# export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
# export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
# export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"

export FZF_DEFAULT_COMMAND="fd --hidden --no-ignore --strip-cwd-prefix --exclude .git --max-depth 3"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type=d --hidden --no-ignore --strip-cwd-prefix --exclude .git --max-depth 3"

# Use fd (https://github.com/sharkdp/fd) for listing path candidates.
# - The first argument to the function ($1) is the base path to start traversal
# - See the source code (completion.{bash,zsh}) for the details.
_fzf_compgen_path() {
  # fd --hidden --exclude .git . "$1"
  fd --hidden --no-ignore --exclude .git --max-depth 3 . "$1"
}

# Use fd to generate the list for directory completion
_fzf_compgen_dir() {
  # fd --type=d --hidden --exclude .git . "$1"
  fd --type=d --hidden --no-ignore --exclude .git --max-depth 3 . "$1"
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

# bun completions - lazy loaded
export BUN_INSTALL="$HOME/.bun"

# Function to lazy load bun
_load_bun() {
  # Source bun completions
  [ -s "$BUN_INSTALL/_bun" ] && source "$BUN_INSTALL/_bun"
  
  # Add bun to PATH
  export PATH="$BUN_INSTALL/bin:$PATH"
  
  # Remove aliases to avoid recursion
  unalias bun bunx 2>/dev/null
}

# Alias bun commands to lazy load
bun() {
    _load_bun
    command bun "$@"
}

bunx() {
    _load_bun
    command bunx "$@"
}


# Load nvm lazily
export NVM_DIR="$HOME/.nvm"

# Load nvm lazily
export NVM_DIR="$HOME/.nvm"
_load_nvm() {
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
  # Unalias nvm and node/npm if they exist to avoid recursion
  unalias nvm 2>/dev/null
  unalias node 2>/dev/null
  unalias npm 2>/dev/null
  # Add nvm's detected Node version to the PATH
  export PATH="$NVM_BIN:$PATH"
}

# Create function wrappers instead of simple aliases to properly handle arguments
nvm() {
  _load_nvm
  command nvm "$@"
}

node() {
  _load_nvm
  command node "$@"
}

npm() {
  _load_nvm
  command npm "$@"
}

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
alias la="eza --color=always --long --git --no-filesize --icons=always --no-time --no-user --no-permissions --all"
alias lsd="eza --color=always --long --git --no-filesize --icons=always --sort=newest --no-user --no-permissions"
alias python="python3"
alias pip="pip3"
alias quartus="wine /Users/user/.wine/drive_c/intelFPGA_lite/18.1/quartus/bin64/quartus.exe"

watch_resume() {
    local file="$1"

    # If no argument is passed, check the current directory for PDF files
    if [[ -z "$file" ]]; then
        # Find PDF files in the current directory (non-recursive)
        pdf_files=($(find . -maxdepth 1 -type f -iname "*.pdf"))

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
        echo "$file" | entr -d python3 /Users/user/Desktop/Projects/termpdf.py/termpdf.py "$file"
    done
}

fuck () {
    TF_PYTHONIOENCODING=$PYTHONIOENCODING;
    export TF_SHELL=zsh;
    export TF_ALIAS=fuck;
    TF_SHELL_ALIASES=$(alias);
    export TF_SHELL_ALIASES;
    TF_HISTORY="$(fc -ln -10)";
    export TF_HISTORY;
    export PYTHONIOENCODING=utf-8;
    TF_CMD=$(
        thefuck THEFUCK_ARGUMENT_PLACEHOLDER $@
    ) && eval $TF_CMD;
    unset TF_HISTORY;
    export PYTHONIOENCODING=$TF_PYTHONIOENCODING;
    test -n "$TF_CMD" && print -s $TF_CMD
}

export JAVA_HOME="/opt/homebrew/opt/openjdk"
export PATH="$JAVA_HOME/bin:$PATH"

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
# The initialization is commented out for performance
# Run 'condainit' command to initialize conda when needed
# <<< conda initialize <<<

# Define condainit function to load conda only when needed
condainit() {
  if [ -f "/opt/anaconda3/etc/profile.d/conda.sh" ]; then
    . "/opt/anaconda3/etc/profile.d/conda.sh"
    echo "Conda initialized successfully. Now you can use 'conda activate <env>'."
  else
    echo "Could not find conda.sh. Please check your Anaconda installation."
    return 1
  fi
}

. "$HOME/.atuin/bin/env"
eval "$(atuin init zsh)"

# Added by Windsurf
export PATH="/Users/user/.codeium/windsurf/bin:$PATH"

# Lazy-load Google Cloud SDK
# The paths to Google Cloud SDK initialization files
gcloud_path_zsh_inc='/Users/user/google-cloud-sdk/path.zsh.inc'
gcloud_completion_zsh_inc='/Users/user/google-cloud-sdk/completion.zsh.inc'

# Function to load Google Cloud SDK
_load_gcloud() {
  # Load Google Cloud SDK paths and completions
  if [[ -f "$gcloud_path_zsh_inc" ]]; then
    source "$gcloud_path_zsh_inc"
  fi
  if [[ -f "$gcloud_completion_zsh_inc" ]]; then
    source "$gcloud_completion_zsh_inc"
  fi
  
  # Remove aliases to avoid recursion
  unalias gcloud gsutil bq 2>/dev/null
}

# Create aliases for common Google Cloud commands
alias gcloud='_load_gcloud && gcloud "$@"'
alias gsutil='_load_gcloud && gsutil "$@"'
alias bq='_load_gcloud && bq "$@"'
eval "$(/Users/user/.local/bin/mise activate zsh)"

ncmsg() {
  if [ "$#" -ne 3 ]; then
    echo "Usage: ncmsg <message> <ip> <port>"
    return 1
  fi

  local message="$1"
  local ip="$2"
  local port="$3"

  echo "$message" | nc "$ip" "$port"
}

slack() {
    secret=$(pass totp/slack)
    oathtool --totp -b "$secret"
}

github() {
    secret=$(pass totp/github)
    oathtool --totp -b "$secret"
}

ip() {
    ipconfig getifaddr en0
}

function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		builtin cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}
