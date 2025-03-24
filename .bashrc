# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]; then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=
export XDG_DATA_HOME="/opt/home/.local/share" 
export XDG_CONFIG_HOME="/opt/home/.config" 
export TERM=xterm-256color

eval "$(zoxide init bash)"
#for gh cli github authentication
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
# User specific aliases and functions
if [ -d ~/.bashrc.d ]; then
    for rc in ~/.bashrc.d/*; do
        if [ -f "$rc" ]; then
            . "$rc"
        fi
    done
fi
unset rc
