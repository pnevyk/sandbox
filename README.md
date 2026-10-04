# Sandbox environment

This repository provides a minimal setup and instructions to quickly run a sandboxed environment.
Use it to isolate AI coding agents from your host system.

It uses [microsandbox](https://docs.microsandbox.dev/getting-started/introduction). See [installation instructions](https://docs.microsandbox.dev/getting-started/quickstart).

## Usage

Download the [configuration files](#configuration) to `~/.config/sandbox`:

```shell
curl -fsSL --create-dirs --output-dir ~/.config/sandbox \
    -O https://raw.githubusercontent.com/pnevyk/sandbox/main/config/msb-config-claude.yaml \
    -O https://raw.githubusercontent.com/pnevyk/sandbox/main/config/msb-config-copilot.yaml
```

The sandbox image is published to `ghcr.io/pnevyk/sandbox/agent-sandbox` and rebuilt weekly.

Create a sandbox with the current directory mounted (Claude Code example):

```shell
CLAUDE_CODE_OAUTH_TOKEN=<token from claude setup-token> msb create ghcr.io/pnevyk/sandbox/agent-sandbox \
    --name my-sandbox \
    --conf ~/.config/sandbox/msb-config-claude.yaml \
    --mount-dir ./:/home/sandbox/workspace
```

Connect to the sandbox:

```shell
msb exec my-sandbox
```

You are all set.

### Local build

Clone this repository, then build the sandbox image from its root and load it into microsandbox:

```shell
git clone https://github.com/pnevyk/sandbox.git
cd sandbox

# default tag: agent-sandbox
bash build-local.sh

# or specify a custom tag
bash build-local.sh custom-tag
```

Use the local tag in place of the published image:

```shell
CLAUDE_CODE_OAUTH_TOKEN=<token from claude setup-token> msb create agent-sandbox \
    --name my-sandbox \
    --conf ~/.config/sandbox/msb-config-claude.yaml \
    --mount-dir ./:/home/sandbox/workspace
```

## Secrets

Store the secrets in the OS keychain instead of in plain text.

### Linux

```shell
# store
secret-tool store --label "Claude Code OAuth Work" type claude-code-oauth-work
# load into env
export CLAUDE_CODE_OAUTH_TOKEN=$(secret-tool lookup type claude-code-oauth-work)
# remove
secret-tool clear type claude-code-oauth-work
```

### macOS

```shell
# store
security add-generic-password -a $USER -s "Claude Code OAuth Work" -w
# load into env
export CLAUDE_CODE_OAUTH_TOKEN=$(security find-generic-password -s "Claude Code OAuth Work" -w)
# remove
security delete-generic-password -s "Claude Code OAuth Work"
```

## Aliases

Optional shell aliases for everyday use:

```shell
# prepare environment for sandbox creation
# create as many presets as you need
# '<msb create vars> ; <secret vars> ' form: secrets apply only to the next command, not the shell
alias sbx-work='SBX_CONFIG="$HOME/.config/sandbox/msb-config-claude.yaml" ; CLAUDE_CODE_OAUTH_TOKEN=$(secret-tool lookup type claude-code-oauth-work) '

# fixed sandbox name based on the current directory
alias sbx-name='echo "$(basename $(pwd))-$(pwd | shasum -a 256 | cut -c1-8)"'

# create a new sandbox for the current working directory
alias sbxc='msb create ghcr.io/pnevyk/sandbox/agent-sandbox --name $(sbx-name) --conf "$SBX_CONFIG" --mount-dir ./:/home/sandbox/workspace'

# connect to the sandbox
alias sbx='msb exec $(sbx-name)'

# delete the sandbox
alias sbxd='msb stop $(sbx-name) && msb rm $(sbx-name)'
```

Combine a preset with `sbxc` to create a sandbox and then connect to it with `sbx`:

```shell
sbx-work sbxc
sbx
```

Rename the aliases as you like.

## Customization

### Configuration

Available configuration files:
- [Claude Code](./config/msb-config-claude.yaml): for agents that use Claude Code with an OAuth subscription (`claude setup-token`).
- [GitHub Copilot](./config/msb-config-copilot.yaml): for agents that use the GitHub Copilot API (`copilot`, `opencode`).

Add your own configuration if none fits.
Contributions are welcome.

### Image

The sandbox image definition is in the [Dockerfile](./Dockerfile).
It is minimal, but it includes common tools and agent harnesses.

Extend the image as needed and use it with a [local build](#local-build).
Contributions are welcome.

## Debugging

The agent inside the sandbox is instructed to log blocking or limiting issues to `~/.sandbox/LOG.md`.
Check it when the agent hits a problem, or from time to time to find sandbox improvements.

Use the following alias to read the log from the host:

```shell
alias sbxl='msb exec $(sbx-name) -- cat /home/sandbox/.sandbox/LOG.md'
```
