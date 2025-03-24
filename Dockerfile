FROM registry.fedoraproject.org/fedora:41

ARG GO_VERSION=1.24.1
ARG GO_BIN="/opt/home/go/bin"
ARG ASDF_VERSION=v0.16.0
ARG ASDF_DATA="/opt/home/.local/asdf"
ARG XSV_VERSION=0.13.0
ARG ZELLIJ_VERSION=v0.42.0
ARG XDG_DATA="/opt/home/.local/share"
ARG XDG_CONFIG="/opt/home/.config"

# Install all packages in one layer
RUN dnf install -y \
    gcc make cmake gdb valgrind \
    tar unzip curl wget git gh jq \
    openssl-devel zlib-devel \
    bzip2-devel readline-devel sqlite-devel \
    ncurses-devel libxml2-devel libffi-devel \
    openssh-server \
    autoconf automake \
    zsh tmux zoxide \
    neovim ripgrep fzf fd sqlite psql \
    python3 python3-pip python3-devel && \
    dnf clean all && \
    rm -rf /var/cache/dnf

# Set up directories and environment variables
RUN mkdir -p ${ASDF_DATA} && \
    mkdir -p ${GO_BIN} && \
    mkdir -p /opt/home/.local/share && \
    mkdir -p /opt/home/.config

ENV GOBIN=${GO_BIN} \
    ASDF_DATA_DIR=${ASDF_DATA} \
    XDG_DATA_HOME=${XDG_DATA} \
    XDG_CONFIG_HOME=${XDG_CONFIG}

# Set up PATH for runtime
ENV PATH=$PATH:/usr/local/go/bin:${GO_BIN}:${ASDF_DATA}/shims

# Install xsv, zellij, go, asdf, and deno all in one layer with proper cleanup
RUN curl -L https://github.com/BurntSushi/xsv/releases/download/${XSV_VERSION}/xsv-${XSV_VERSION}-x86_64-unknown-linux-musl.tar.gz | tar xzf - -C /usr/local/bin && \
    curl -L https://github.com/zellij-org/zellij/releases/download/${ZELLIJ_VERSION}/zellij-x86_64-unknown-linux-musl.tar.gz | tar xzf - -C /usr/local/bin && \
    wget -q https://golang.org/dl/go${GO_VERSION}.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf go${GO_VERSION}.linux-amd64.tar.gz && \
    rm go${GO_VERSION}.linux-amd64.tar.gz && \
    export PATH=$PATH:/usr/local/go/bin && \
    go install github.com/asdf-vm/asdf/cmd/asdf@${ASDF_VERSION} && \
    export PATH=$PATH:$GOPATH/bin:${ASDF_DATA}/shims && \
    asdf plugin add deno https://github.com/asdf-community/asdf-deno.git && \
    asdf install deno latest && \
    asdf set -u deno latest



RUN git clone --depth 1 https://github.com/brightblade42/kickstart.nvim ${XDG_CONFIG}/nvim

#Enable nerd fonts
RUN dnf copr enable -y aquacash5/nerd-fonts
RUN dnf install -y fira-code-nerd-fonts

RUN dnf copr enable -y varlad/yazi 
RUN dnf install yazi -y
# Copy configuration files
COPY ./.bashrc /opt/home/.bashrc
COPY ./ssh /opt/home/.ssh
#for preloading nvim plugins.
COPY ./local/share /opt/home/.local/share
#copy preinstalled neovim plugins. 
