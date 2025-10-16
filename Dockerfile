FROM registry.fedoraproject.org/fedora:latest

LABEL maintainer="brightblade42@protonmail.com"
LABEL description="Fedora development environment for Distrobox with mise. (Kitchen sink version)"
LABEL version="2.0"

# Install system packages and build dependencies
RUN dnf update -y && \
    dnf install -y \
    sudo passwd shadow-utils procps-ng \
    which findutils util-linux \
    zsh bash fish bash-completion \
    kitty alacritty \
    gcc gcc-c++ make cmake ninja-build meson \
    gdb valgrind strace pkg-config \
    autoconf automake libtool \
    tar gzip bzip2 xz unzip zip \
    curl wget openssh-clients rsync \
    git git-lfs gh fossil \
    openssl-devel zlib-devel \
    libffi-devel libcurl-devel \
    expat-devel \
    ripgrep fd-find bat zoxide fzf \
    jq yq tree ncdu \
    parallel btop nvtop \
    neovim helix emacs \
    tmux sqlite postgresql \
    dust duf procs  tokei hyperfine delta just \
    && dnf clean all && \
    rm -rf /var/cache/dnf


# Install eza (modern ls replacement) from GitHub releases
RUN EZA_VERSION=$(curl -s https://api.github.com/repos/eza-community/eza/releases/latest | grep '"tag_name"' | sed -E 's/.*"v([^"]+)".*/\1/') && \
    curl -L "https://github.com/eza-community/eza/releases/download/v${EZA_VERSION}/eza_x86_64-unknown-linux-gnu.tar.gz" -o /tmp/eza.tar.gz && \
    tar -xzf /tmp/eza.tar.gz -C /usr/local/bin && \
    chmod +x /usr/local/bin/eza && \
    rm /tmp/eza.tar.gz


# mise - modern version manager
RUN dnf install -y dnf-plugins-core && \
    dnf config-manager addrepo \
      --from-repofile=https://mise.jdx.dev/rpm/mise.repo && \
    dnf install -y mise && \
    dnf clean all

#deps for some rust compilations
RUN dnf install -y perl-Text-Template perl-FindBin openssl-devel pkg-config perl-IPC-Cmd perl-Text-Template perl-FindBin

# Setup mise activation for all shells
RUN mkdir -p /etc/skel/.config/fish && \
    echo 'eval "$(mise activate bash)"' >> /etc/skel/.bashrc && \
    echo 'eval "$(mise activate zsh)"' >> /etc/skel/.zshrc && \
    echo 'mise activate fish | source' >> /etc/skel/.config/fish/config.fish

# Setup zoxide for all shells
RUN echo 'eval "$(zoxide init bash)"' >> /etc/skel/.bashrc && \
    echo 'eval "$(zoxide init zsh)"' >> /etc/skel/.zshrc && \
    echo 'zoxide init fish | source' >> /etc/skel/.config/fish/config.fish


# Install Zellij terminal multiplexer
RUN ZELLIJ_VERSION=$(curl -s https://api.github.com/repos/zellij-org/zellij/releases/latest | grep '"tag_name"' | sed -E 's/.*"v([^"]+)".*/\1/') && \
    curl -L "https://github.com/zellij-org/zellij/releases/download/v${ZELLIJ_VERSION}/zellij-x86_64-unknown-linux-musl.tar.gz" -o /tmp/zellij.tar.gz && \
    tar -xzf /tmp/zellij.tar.gz -C /usr/local/bin && \
    chmod +x /usr/local/bin/zellij && \
    rm /tmp/zellij.tar.gz

# Install Mutagen for file/network syncing
RUN MUTAGEN_VERSION=$(curl -s https://api.github.com/repos/mutagen-io/mutagen/releases/latest | grep '"tag_name"' | sed -E 's/.*"v([^"]+)".*/\1/') && \
    curl -L "https://github.com/mutagen-io/mutagen/releases/download/v${MUTAGEN_VERSION}/mutagen_linux_amd64_v${MUTAGEN_VERSION}.tar.gz" -o /tmp/mutagen.tar.gz && \
    tar -xzf /tmp/mutagen.tar.gz -C /usr/local/bin mutagen && \
    chmod +x /usr/local/bin/mutagen && \
    rm /tmp/mutagen.tar.gz

# COPR: Nerd Fonts
RUN dnf copr enable -y aquacash5/nerd-fonts && \
    dnf install -y \
      jet-brains-mono-nerd-fonts \
      fira-code-nerd-fonts \
      cascadia-mono-nerd-fonts \
      cascadia-code-nerd-fonts \
      zed-mono-nerd-fonts \
      hack-nerd-fonts \
    && dnf clean all || echo "Nerd fonts installation failed, continuing..."

# COPR: atac - API client TUI
RUN dnf copr enable -y joxcat/atac && \
    dnf install -y atac && \
    dnf clean all || echo "atac installation failed, continuing..."

#install Zed, zed's dead, baby. Zed's dead.
#RUN curl -f https://zed.dev/install.sh | sh

# Create helpful aliases
RUN cat >> /etc/skel/.bashrc << 'EOF'

# Modern CLI aliases
alias ll='eza -la'
alias lt='eza --tree'
alias ls='eza'
alias cat='bat --paging=never'
alias find='fd'
alias grep='rg'
alias ps='procs'
alias top='btop'
alias du='dust'
alias df='duf'

# Git aliases
alias gs='git status'
alias gd='git diff'
alias gl='git log --oneline --graph'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gco='git checkout'

# Directory navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Terminal multiplexers
alias zj='zellij'

# Set environment variables
ENV EDITOR=nvim
ENV VISUAL=nvim
ENV PAGER=less

# Expose common development ports (documentation only)
EXPOSE 3000 4200 5000 8000 8080 9000

CMD ["/bin/bash"]
