#!/bin/bash

# Detect OS and install Docker + lazydocker
if [ -f /etc/arch-release ]; then
    echo "Arch Linux detected. Installing via pacman..."
    sudo pacman -S --noconfirm docker lazydocker
    sudo systemctl enable --now docker.service
elif [ -f /etc/lsb-release ] || [ -f /etc/debian_version ]; then
    echo "Ubuntu/Debian detected. Installing via get.docker.com..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    rm get-docker.sh
    sudo systemctl enable --now docker

    echo "Installing lazydocker..."
    # lazydocker doesn't have an official deb repo, using the recommended install script
    curl https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh | bash
else
    echo "Unsupported OS. Please install Docker and lazydocker manually."
    exit 1
fi

# One step in the Linux post-installation steps is to manage Docker as a non-root user.
# To do this, you can add your user account to the docker group.
# This allows you to run Docker commands without using sudo them every time.
# However, it is important to note that adding a user to the docker group grants
# them significant privileges, as Docker allows direct access to the host system.
# Therefore, exercise caution when granting Docker access to non-root users,
# as it can potentially lead to security vulnerabilities if not properly managed
# and monitored.
sudo groupadd docker 2>/dev/null || true
sudo usermod -aG docker "$USER"

echo "------------------------------------------------------------"
echo "Installation complete!"
echo "Note: You may need to log out and back in for the 'docker' group changes to take effect."
echo "Alternatively, run 'newgrp docker' in your current terminal session."
echo "------------------------------------------------------------"
