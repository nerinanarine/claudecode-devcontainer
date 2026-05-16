FROM node:22-bookworm-slim

# Install necessary packages
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get install -y \
        git \
        curl \
        wget \
        sudo \
        procps \
        less \
        jq \
        bash-completion \
        python3 \
        python3-pip \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user (vscode)
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN if ! getent group "$USER_GID" > /dev/null 2>&1; then groupadd --gid "$USER_GID" "$USERNAME"; fi \
    && if id -u "$USERNAME" > /dev/null 2>&1; then \
        usermod --uid "$USER_UID" --gid "$USER_GID" "$USERNAME"; \
    elif getent passwd "$USER_UID" > /dev/null 2>&1; then \
        EXISTING_USER="$(getent passwd "$USER_UID" | cut -d: -f1)"; \
        usermod --login "$USERNAME" --home "/home/$USERNAME" --move-home "$EXISTING_USER"; \
        usermod --gid "$USER_GID" "$USERNAME"; \
    else \
        useradd --uid "$USER_UID" --gid "$USER_GID" -m "$USERNAME" -s /bin/bash; \
    fi \
    && echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

# Install Claude Code globally
RUN npm install -g @anthropic-ai/claude-code

# Install uv and Speckit (specify-cli)
RUN curl -LsSf https://astral.sh/uv/install.sh | UV_INSTALL_DIR=/usr/local/bin sh \
    && UV_TOOL_DIR=/opt/uv-tools UV_TOOL_BIN_DIR=/usr/local/bin \
       uv tool install specify-cli --from git+https://github.com/github/spec-kit.git

# Store Claude Code defaults in /opt/claude-defaults/
# (~/.claude/ is bind-mounted from host at runtime; init-claude.sh merges these on container start)
RUN mkdir -p /opt/claude-defaults/skills /opt/claude-defaults/plugins

COPY claude/settings.json /opt/claude-defaults/settings.json
COPY claude/skills/ /opt/claude-defaults/skills/
COPY claude/plugins/ /opt/claude-defaults/plugins/
COPY init-claude.sh /usr/local/bin/init-claude.sh
RUN chmod +x /usr/local/bin/init-claude.sh

USER $USERNAME

WORKDIR /work
