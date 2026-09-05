# ------------------------------------------------------------------------------
# 2. Environment & Helpers
# ------------------------------------------------------------------------------
export EDITOR="nvim"
export VISUAL="nvim"
export BAT_THEME=tokyonight_night   # was 'ansi'; pinned so bat uses full Tokyo Night syntax colours


# ------------------------------------------------------------------------------
# 0. Helpers
# ------------------------------------------------------------------------------
# NOTE: bash requires a `;` (or newline) before the closing `}` of a function.
maybe_source() { [[ -f "$1" ]] && source "$1"; return 0; }

# ------------------------------------------------------------------------------
# 3. Path Building
# ------------------------------------------------------------------------------
# bash has no $path array and no `typeset -U`, so we emulate both:
# path_prepend skips missing dirs and refuses to add duplicates.
path_prepend() {
    [[ -d "$1" ]] || return 0
    case ":${PATH}:" in
        *":$1:"*) ;;
        *) PATH="$1${PATH:+:$PATH}" ;;
    esac
}

path_append() {
    [[ -d "$1" ]] || return 0
    case ":${PATH}:" in
        *":$1:"*) ;;
        *) PATH="${PATH:+$PATH:}$1" ;;
    esac
}

# Prepend in reverse order so the final PATH matches the original listing.
path_prepend "$HOME/.duckdb/cli/latest"
path_prepend "$HOME/.cargo/bin"
path_prepend "$HOME/.local/bin"
export PATH

# Homebrew (Linux/Mac safe)
if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /home/linuxbrew/.linuxbrew/bin/brew ]]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# Node.js (pnpm)
export PNPM_HOME="$HOME/.local/share/pnpm"
path_prepend "$PNPM_HOME"

# Go
export GOPATH="${GOPATH:-$HOME/go}"
path_prepend "$GOPATH/bin"

# Ruby
GEM_PATH="$(ruby -e 'print Gem.user_dir' 2>/dev/null)"
path_prepend "$GEM_PATH/bin"
unset GEM_PATH   # avoid clobbering the real GEM_PATH variable rubygems uses

export PATH

# ------------------------------------------------------------------------------
# 6. Tool Initializations
# ------------------------------------------------------------------------------
# maybe_source "$HOME/.atuin/bin/env"
# eval "$(atuin init bash)"      # needs bash-preexec


# export CARAPACE_BRIDGES='zsh,fish,bash,inshellisense'
# source <(carapace _carapace bash)             # no zstyle equivalent in bash

# ------------------------------------------------------------------------------
# 7. Aliases & Functions
# ------------------------------------------------------------------------------
# Aliases are only expanded in interactive shells by default.
# Uncomment if you source this file from scripts:
# shopt -s expand_aliases

function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	command yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd"
	command rm -f -- "$tmp"
}

alias ls='eza -lh --group-directories-first --icons=auto'
alias lsa='ls -a'
alias lt='eza --tree --level=2 --long --icons --git'
alias lta='lt -a'
alias lt2="lt"
alias lta2="lta"
alias lt3="lt --level=3"
alias lta3="lt3 -a"

alias gs="git status"
alias gc="git commit"
alias gd="git diff"
alias gds="git diff --staged"
alias gp="git pull"
alias gP="git push"
alias gfa="git fetch --all"
alias gol="git log --pretty=oneline"
alias golg="git log --graph --decorate --pretty=oneline --abbrev-commit"
alias ghd='gh dash'

alias lg="lazygit"
alias ld="lazydocker"
# Tabiew dropped --theme; it now follows the terminal palette.

alias delta="delta --hyperlinks --hyperlinks-file-link-format='file://{path}#{line}'"
alias rg='rg --hyperlink-format=kitty'

# bash has no global aliases (`alias -g`), so `-h` / `--help` can't be rewritten
# mid-command. Closest equivalent: a wrapper you put in *front* of the command.
#   h git commit        ->  git commit --help | bat
h() { "$@" --help 2>&1 | bat --language=help --style=plain; }
bathelp() { bat --language=help --style=plain; }   # for piping: cmd -h | bathelp

alias sail='sh $([ -f sail ] && echo sail || echo vendor/bin/sail)'

# Tokyo Night colours for fzf
[ -r "$HOME/.config/fzf/tokyonight_night.sh" ] && . "$HOME/.config/fzf/tokyonight_night.sh"
