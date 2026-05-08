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

USER $USERNAME

WORKDIR /workspace
