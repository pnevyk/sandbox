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
