FROM nvcr.io/nvidia/base/ubuntu:24.04

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl git gh jq ripgrep fzf vim nano python3

RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.8/install.sh | bash \
    && . "$HOME/.nvm/nvm.sh" \
    && nvm install 24 \
    && ln -s "$NVM_DIR/versions/node/$(nvm version 24)/bin/"* /usr/local/bin/

RUN npm install -g --prefix /usr/local \
    @anthropic-ai/claude-code \
    @opencode/cli \
    @github/copilot

ENV SHELL=bash
RUN curl -fsSL https://get.pnpm.io/install.sh | sh -

RUN useradd -m sandbox
USER sandbox

RUN mkdir -p ~/workspace && mkdir -p ~/.sandbox/assets/ && touch ~/.sandbox/LOG.md

RUN mkdir -p ~/.agents && mkdir -p ~/.claude
COPY --chown=sandbox:sandbox sources/general/AGENTS.md /home/sandbox/.agents/AGENTS.md
RUN ln -s ~/.agents/AGENTS.md ~/.claude/CLAUDE.md
COPY --chown=sandbox:sandbox sources/claude/.claude.json /home/sandbox/.claude.json
COPY --chown=sandbox:sandbox sources/claude/settings.json /home/sandbox/.claude/settings.json
COPY --chown=sandbox:sandbox sources/claude/statusline.sh /home/sandbox/.claude/statusline.sh
COPY --chown=sandbox:sandbox sources/opencode/opencode.jsonc /home/sandbox/.config/opencode/opencode.jsonc

WORKDIR /home/sandbox/workspace
