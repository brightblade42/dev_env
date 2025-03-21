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
RUN dnf update -y && \
    dnf install -y \
    gcc make cmake gdb valgrind \
    tar unzip curl wget git gh jq \
    openssl-devel zlib-devel \
    bzip2-devel readline-devel sqlite-devel \
    ncurses-devel libxml2-devel libffi-devel \
    openssh-server \
    autoconf automake \
    zsh tmux \
    neovim ripgrep fzf sqlite psql \
    python3 python3-pip python3-devel  \
    nvtop btop bat eza parallel && \
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
    XDG_CONFIG_HOME=${XDG_CONFIG} \
    PATH=$PATH:/usr/local/bin:/usr/local/go/bin:${GO_BIN}:${ASDF_DATA}/shims

# Install: 
# -xsv
# -zellij
# -go,
# -asdf
# -lazygit
# -deno
# -nerd font, 
# -atac (think postman but terminal)

RUN curl -L https://github.com/BurntSushi/xsv/releases/download/${XSV_VERSION}/xsv-${XSV_VERSION}-x86_64-unknown-linux-musl.tar.gz | tar xzf - -C /usr/local/bin && \
    curl -L https://github.com/zellij-org/zellij/releases/download/${ZELLIJ_VERSION}/zellij-x86_64-unknown-linux-musl.tar.gz | tar xzf - -C /usr/local/bin && \
    wget -q https://golang.org/dl/go${GO_VERSION}.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf go${GO_VERSION}.linux-amd64.tar.gz && \
    rm go${GO_VERSION}.linux-amd64.tar.gz && \
    go install github.com/asdf-vm/asdf/cmd/asdf@${ASDF_VERSION} && \
    go install github.com/jesseduffield/lazygit@latest  && \
    asdf plugin add deno https://github.com/asdf-community/asdf-deno.git && \
    asdf install deno latest && \
    asdf set -u deno latest && \
    dnf copr enable -y aquacash5/nerd-fonts && \
    dnf copr enable -y  joxcat/atac && \
    dnf install -y atac jet-brains-mono-nerd-fonts && \
    curl -sLo- https://superfile.netlify.app/install.sh | sh 

# Install Erlang and Elixir using asdf
#ARG ERLANG_VERSION=27.0.1
#ARG ELIXIR_VERSION=1.17.2-otp-27
#RUN . /opt/asdf/asdf.sh && \
#  asdf plugin add erlang https://github.com/asdf-vm/asdf-erlang.git && \
#  asdf plugin add elixir https://github.com/asdf-vm/asdf-elixir.git && \
#  asdf install erlang ${ERLANG_VERSION} && \
#  asdf install elixir ${ELIXIR_VERSION} && \
#  asdf global erlang ${ERLANG_VERSION} && \
#  asdf global elixir ${ELIXIR_VERSION} && \
#  mix local.hex --force && \
#  mix local.rebar --force

# Install Zig
#ARG ZIG_VERSION=0.13.0
#RUN wget https://ziglang.org/download/${ZIG_VERSION}/zig-linux-x86_64-${ZIG_VERSION}.tar.xz && \
# tar -xf zig-linux-x86_64-${ZIG_VERSION}.tar.xz && \
# mv zig-linux-x86_64-${ZIG_VERSION} /usr/local/zig && \
#   rm zig-linux-x86_64-${ZIG_VERSION}.tar.xz
#ENV PATH=$PATH:/usr/local/zig

#install rust
#ENV PATH="/root/.cargo/bin:${PATH}"
#RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
#RUN rustup default stable

# may put these in another image based on this one it adds over 500mb. 
#command line and tui tools.
#sql tui
#RUN dnf install -y psql && \
#    curl -Lo uv.tar.gz https://github.com/astral-sh/uv/releases/latest/download/uv-x86_64-unknown-linux-gnu.tar.gz && \
#    tar -xzf uv.tar.gz -C /usr/local/bin --strip-components=1 && \
#    chmod +x /usr/local/bin/uv && \
#     uv tool install harlequin && \
#    uv tool install 'harlequin[postgres]' && \
#    go install github.com/gcla/termshark/v2/cmd/termshark@v2.4.0


# Copy configuration files
RUN git clone --depth 1 https://github.com/brightblade42/kickstart.nvim ${XDG_CONFIG}/nvim
COPY ./.bashrc /opt/home/.bashrc
COPY ./ssh /opt/home/.ssh
