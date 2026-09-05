#!/bin/bash

set -e # Exit on any error

# --- Configuration ---
DOTFILES_DIR="$HOME/dotfiles"
LOG_FILE="$HOME/bootstrap.log"

echo "🚀 Starting bootstrap..." | tee -a "$LOG_FILE"

# --- 1. Environment Detection ---
if [ -d "/data/data/com.termux" ]; then
  OS="termux"
  INSTALL_CMD="pkg install -y"
  UPDATE_CMD="pkg update -y"
elif [ -f /etc/os-release ]; then
  . /etc/os-release
  OS=$ID
  case $OS in
  arch)
    INSTALL_CMD="sudo pacman -S --needed --noconfirm"
    UPDATE_CMD="sudo pacman -Sy"
    ;;
  ubuntu | debian | pop)
    OS="ubuntu"
    INSTALL_CMD="sudo apt-get install -y"
    UPDATE_CMD="sudo apt-get update"
    ;;
  *)
    echo "⚠️ Unknown OS: $OS. Proceeding with caution..."
    OS="unknown"
    ;;
  esac
fi

echo "Detected OS: $OS"
$UPDATE_CMD

# --- 2. Base Dependencies ---
echo "🛠️ Installing base dependencies..."
case $OS in
arch)
  $INSTALL_CMD curl ca-certificates sudo
  ;;
ubuntu)
  $INSTALL_CMD curl ca-certificates sudo
  ;;
termux)
  $INSTALL_CMD curl
  ;;
esac

# --- 3. Package Installation ---
echo "📦 Installing tools and dependencies..."

TOOLS=(
  "bat:bat:bat:bat"
  "btop:btop:btop:btop"
  "eza:eza:eza:eza"
  "fd:fd:fd-find:fd"
  "fzf:fzf:fzf:fzf"
  "gh:github-cli:gh:gh"
  "git:git:git:git"
  "jq:jq:jq:jq"
  "neovim:neovim:neovim:neovim"
  "ripgrep:ripgrep:ripgrep:ripgrep"
  "starship:starship:starship:starship"
  "stow:stow:stow:stow"
  "tmux:tmux:tmux:tmux"
  "zoxide:zoxide:zoxide:zoxide"
  "zsh:zsh:zsh:zsh"
  # Git & CLI UI
  "delta:git-delta:git-delta:git-delta"
  "lazygit:lazygit:-:lazygit"
  "yazi:yazi:-:yazi"
  "carapace:-:-:carapace" # Ubuntu/Arch handled below
  # Shell Plugins
  "zsh-autosuggestions:zsh-autosuggestions:zsh-autosuggestions:zsh-autosuggestions"
  "zsh-syntax-highlighting:zsh-syntax-highlighting:zsh-syntax-highlighting:zsh-syntax-highlighting"
  # Dependencies & Extras
  "gcc:gcc:build-essential:clang"
  "ffmpeg:ffmpeg:ffmpeg:ffmpeg"
  "fontconfig:fontconfig:fontconfig:fontconfig"
  "unzip:unzip:unzip:unzip"
  "7zip:7zip:7zip:7zip"
  "poppler:poppler:poppler-utils:poppler"
  "imagemagick:imagemagick:imagemagick:imagemagick"
  "resvg:resvg:resvg:resvg"
)

for entry in "${TOOLS[@]}"; do
  IFS=":" read -r name arch_pkg ubuntu_pkg termux_pkg <<<"$entry"

  case $OS in
  arch) pkg=$arch_pkg ;;
  ubuntu) pkg=$ubuntu_pkg ;;
  termux) pkg=$termux_pkg ;;
  esac

  if [ "$pkg" != "-" ]; then
    echo "Installing $name ($pkg)..."
    $INSTALL_CMD "$pkg"
  fi
done

# --- 3. Shell Setup (ZSH) ---
if [[ "$SHELL" != *"zsh"* ]]; then
  echo "🐚 Changing shell to ZSH..."
  if [ "$OS" == "termux" ]; then
    chsh -s "$(which zsh)" || echo "⚠️ Failed to change shell."
  else
    sudo chsh -s "$(which zsh)" "$USER" || echo "⚠️ Failed to change shell automatically. Run 'chsh -s $(which zsh)' later."
  fi
fi

# --- 4. Special Tool Installers ---

# Ubuntu/Arch specific manual installs
if [ "$OS" == "ubuntu" ]; then
    # Lazygit (Ubuntu)
    if ! command -v lazygit &>/dev/null; then
        echo "Installing lazygit..."
        LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
        curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
        tar xf lazygit.tar.gz lazygit
        sudo install lazygit /usr/local/bin
        rm lazygit.tar.gz lazygit
    fi

    # Yazi (Ubuntu)
    if ! command -v yazi &>/dev/null; then
        echo "Installing yazi..."
        # Using pre-built binary for simplicity
        curl -Lo yazi.zip "https://github.com/sxyazi/yazi/releases/latest/download/yazi-x86_64-unknown-linux-gnu.zip"
        unzip yazi.zip
        sudo install yazi-x86_64-unknown-linux-gnu/yazi yazi-x86_64-unknown-linux-gnu/ya /usr/local/bin
        rm -rf yazi.zip yazi-x86_64-unknown-linux-gnu
    fi

    # resvg (Ubuntu)
    if ! command -v resvg &>/dev/null; then
        echo "Installing resvg..."
        curl -Lo resvg.tar.gz "https://github.com/RazrFalcon/resvg/releases/latest/download/resvg-linux-x86_64.tar.gz"
        tar xf resvg.tar.gz
        sudo install resvg /usr/local/bin
        rm resvg.tar.gz resvg
    fi
fi

# Carapace (Arch/Ubuntu)
if ! command -v carapace &>/dev/null && [ "$OS" != "termux" ]; then
    echo "📦 Installing Carapace..."
    curl -fsSL https://raw.githubusercontent.com/carapace-sh/carapace-bin/master/install.sh | sh
fi

# DuckDB
if ! command -v duckdb &>/dev/null; then
  echo "🦆 Installing DuckDB..."
  ARCH_TYPE=$(uname -m)
  case "$ARCH_TYPE" in
    x86_64)  PLATFORM="linux-amd64" ;;
    aarch64) PLATFORM="linux-arm64" ;;
    *)       PLATFORM="linux-amd64" ;; # Fallback
  esac
  [ "$OS" == "termux" ] && PLATFORM="android-arm64"
  DUCKDB_URL="https://github.com/duckdb/duckdb/releases/latest/download/duckdb_cli-${PLATFORM}.zip"
  curl -Lo duckdb.zip "$DUCKDB_URL"
  unzip -o duckdb.zip -d "$HOME/.local/bin"
  rm duckdb.zip
fi

# Atuin
if ! command -v atuin &>/dev/null; then
  echo "📊 Installing Atuin..."
  curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh
fi

# Mise (Version Manager)
if ! command -v mise &>/dev/null; then
  echo "📦 Installing Mise..."
  if [ "$OS" == "arch" ]; then
    $INSTALL_CMD mise
  else
    curl https://mise.run | sh
    export PATH="$HOME/.local/bin:$PATH"
  fi
fi

# UV (Python Tool)
if ! command -v uv &>/dev/null; then
  echo "🐍 Installing uv..."
  curl -LsSf https://astral.sh/uv/install.sh | sh
  export PATH="$HOME/.cargo/bin:$PATH"
fi

# --- 5. Tool Configuration ---

echo "🐍 Setting up Python tools via uv..."
if command -v uv &>/dev/null; then
  uv tool install --upgrade pynvim || true
  uv tool install ruff@latest || true
fi

echo "📦 Setting up Node tools via mise..."
if command -v mise &>/dev/null; then
  eval "$(mise activate bash)"
  mise use --global node@latest
  npm install -g neovim @mermaid-js/mermaid-cli
fi

# --- 6. Dotfiles Management (Stow) ---
if [ -d "$DOTFILES_DIR" ]; then
  echo "🔗 Stowing dotfiles..."
  cd "$DOTFILES_DIR"
  # Stow each directory individually as a package
  for dir in */; do
    dir=${dir%/}
    if [[ "$dir" != ".git" && "$dir" != "bin" ]]; then
      stow -t "$HOME" "$dir"
    fi
  done
else
  echo "⚠️ Dotfiles directory ($DOTFILES_DIR) not found. Skipping stow."
fi

# --- 7. Tmux Plugin Manager ---
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
  echo "🪟 Installing TPM..."
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

# --- 8. OS Specific Extras & Fonts ---

# Ubuntu 1Password
if [ "$OS" == "ubuntu" ] && ! command -v op &>/dev/null; then
  echo "🔐 Installing 1Password CLI..."
  ARCH=$(dpkg --print-architecture)
  curl -sS https://downloads.1password.com/linux/keys/1password.asc | sudo gpg --dearmor --output /usr/share/keyrings/1password-archive-keyring.gpg
  echo "deb [arch=$ARCH signed-by=/usr/share/keyrings/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/$ARCH stable main" | sudo tee /etc/apt/sources.list.d/1password.list
  sudo apt-get update && sudo apt-get install 1password-cli
fi

# 0xProto Nerd Font (Cross-Platform)
echo "🔤 Installing 0xProto Nerd Font..."
FONT_ZIP="/tmp/0xProto.zip"
curl -fLo "$FONT_ZIP" "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/0xProto.zip"

if [ "$OS" == "termux" ]; then
  echo "📱 Applying font to Termux..."
  mkdir -p "$HOME/.termux"
  mkdir -p "/tmp/termux-font"
  unzip -q -o "$FONT_ZIP" -d "/tmp/termux-font"
  FONT_FILE=$(find "/tmp/termux-font" -name "*NerdFont-Regular.ttf" -not -name "*Mono*" -not -name "*Propo*" | head -n 1)
  if [ -z "$FONT_FILE" ]; then
    FONT_FILE=$(find "/tmp/termux-font" -name "*.ttf" | head -n 1)
  fi
  cp "$FONT_FILE" "$HOME/.termux/font.ttf"
  rm -rf "/tmp/termux-font"
  am broadcast -a com.termux.app.reload_style com.termux &>/dev/null || true
else
  FONT_DIR="$HOME/.local/share/fonts/0xProto"
  if [ ! -d "$FONT_DIR" ]; then
    echo "💻 Installing to $FONT_DIR..."
    mkdir -p "$FONT_DIR"
    unzip -q -o "$FONT_ZIP" -d "$FONT_DIR"
    fc-cache -fv
  else
    echo "✅ 0xProto already installed in $FONT_DIR"
  fi
fi
rm -f "$FONT_ZIP"

# --- Final Steps ---
echo "✅ Bootstrap complete!"

# Theme check (Non-Arch)
if [ "$OS" != "arch" ]; then
    THEME_PHYSICAL="$HOME/.config/nvim/lua/plugins/theme.lua.physical"
    THEME_TARGET="$HOME/.config/nvim/lua/plugins/theme.lua"
    if [ -f "$THEME_PHYSICAL" ] && [ ! -f "$THEME_TARGET" ]; then
        echo "🎨 Detected physical theme file but no theme.lua..."
        read -p "Restore theme.lua from physical copy? (y/N) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            cp "$THEME_PHYSICAL" "$THEME_TARGET"
            echo "✅ Theme restored."
        fi
    fi
fi

echo "👉 Action Items:"
echo "   1. Restart your terminal."
echo "   2. Run 'atuin login' to sync shell history."
echo "   3. Open tmux and press 'prefix + I' to install plugins."
