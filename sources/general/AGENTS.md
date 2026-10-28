# Sandbox environment

You are running inside an isolated sandbox container (microsandbox), not a full developer machine.

## Environment

- Base image: Ubuntu Noble.
- Network: default-deny. Only DNS and LLM providers are reachable. No general internet access.
- `~/workspace` is a host-mounted volume. Nothing outside mounted paths persists.

## Logging sandbox issues

If you hit a problem that is likely caused by the sandbox itself (network denial, missing binary, permission issue, mount quirk, etc.), append one compact line to `~/.sandbox/LOG.md`:

`- [timestamp] (severity - blocking | limiting): brief description of the problem and why it matters`

If more detail is useful (raw logs, error output, possible fixes), save it under `~/.sandbox/assets/<problem-slug>/` and reference the path in the log line.

## Sandbox boundaries

Do not attempt to escape the sandbox. Work within the mounted paths and the allowed network destinations. Never try to bypass, disable, or work around the container's isolation or network restrictions. If a restriction blocks the task, log it as a sandbox issue instead.

## Workarounds

Known fixes for sandbox limitations.
Apply a workaround only when its condition matches.

### Claude Code plugins are not enabled

Condition: you run as Claude Code, the user wants plugins from the host, and the workspace `.claude/settings.local.json` has no `enabledPlugins`.

The host's `~/.claude/plugins` is mounted read-only, but plugin enablement lives in the settings, which are not shared with the host.

1. Read the plugin keys (`name@marketplace`) from `~/.claude/plugins/installed_plugins.json`.
   Use only the entries installed at user scope.
   Project-scoped installs are keyed to the host's project paths and do not work.
2. Merge the keys into `enabledPlugins` in `~/.claude/settings.json`, for example `{"enabledPlugins": {"name@marketplace": true}}`.
   Keep the existing content of the file.
3. Tell the user to run `/reload-plugins`.
   Also tell them that this change is lost when the sandbox is removed, and that `.claude/settings.local.json` in the workspace persists.
