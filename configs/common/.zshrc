# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# If you come from bash you might have to change your $PATH.
export PATH=$PATH:$HOME/bin

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="powerlevel10k/powerlevel10k"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to automatically update without prompting.
# DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
    git
    git-prompt
    gh
    vscode
    kubectl
    fzf
    kube-ps1
    k9s
    python
    gradle
    npm
    mise
    uv
    zoxide
    gcloud
    tmux
    docker
    brew
    rust
    docker-compose
    podman
    terraform
    jj
    kitty
    tldr
    eza
)

# Must be set before oh-my-zsh.sh: the eza plugin reads these at load time.
zstyle ':omz:plugins:eza' 'icons' yes

source $ZSH/oh-my-zsh.sh

# Prefer omz's plugin-generated completions over Homebrew's. Both ship a
# `_<tool>` for jj/gh/mise/etc, and fpath order silently decides the winner.
# Homebrew generates its copies at install time, so clap-based ones embed an
# absolute Cellar path (.../Cellar/jj/<version>/bin/jj) that dies on
# `brew upgrade` and then fails silently in already-running shells, since a
# loaded compdef function is never re-read. The omz plugins regenerate at
# startup from $PATH, so their copies survive upgrades. Safe after compinit:
# it records only the function name, and fpath decides which file that name
# loads from at first completion.
fpath=("$ZSH_CACHE_DIR/completions" ${fpath:#$ZSH_CACHE_DIR/completions})

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

export EDITOR='nvim'

# Load all jj config files from the config directory (allows local overrides)
export JJ_CONFIG="$HOME/.config/jj/"

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

#Convinient functions and aliases

# Make directory and change into it.
function mcd() {
    mkdir -p "$1" && cd "$1";
}

#K8s stuff
# Note: the oh-my-zsh "kubectx" plugin is not a substitute for these. It only
# defines kubectx_prompt_info for hand-built PROMPTs (inert under p10k) and
# never calls the kubectx/kubens binaries. Prod-context coloring lives in
# POWERLEVEL9K_KUBECONTEXT_CLASSES in .p10k.zsh instead.
alias kctx="kubectx"
alias kns="kubens"
alias ar="kubectl argo rollouts"
complete -F __start_kubectl k

#GIT
alias gci='git commit -a -m'
alias gbc='git fetch && git checkout origin/$(git_main_branch) -b'
alias gbp='git push origin $(current_branch)'

#JJ
alias jji='jj git init --colocate'
alias jjf='jj git fetch'
alias jjp='jj git push'

# -- supercharge fzf --
show_file_or_dir_preview="if [ -d {} ]; then eza --tree --color=always {} | head -200; else bat -n --color=always --line-range :500 {}; fi"
export FZF_CTRL_T_OPTS="--preview '$show_file_or_dir_preview'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"
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

# ---- bat (better cat) -----
alias cat='bat'
# ---- Eza (better ls) -----
# ls/ll/la/lS/lT come from the oh-my-zsh eza plugin
# ---- Zoxide (better cd) ----
# init comes from the oh-my-zsh zoxide plugin
alias cd="z"

# Local overrides
[[ -s "$HOME/.zshrc-local" ]] && source "$HOME/.zshrc-local"

# Load zsh-syntax-highlighting
if command -v brew &>/dev/null; then
  # macOS with Homebrew
  source "$(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
elif [ -f "/usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]; then
  # Linux standard location
  source "/usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
elif [ -f "$HOME/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]; then
  # Manual installation in home directory
  source "$HOME/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# gcloud, uv/uvx completions and mise activation come from their oh-my-zsh plugins
export PATH="$HOME/.local/bin:$PATH"

. "$HOME/.cargo/env"
