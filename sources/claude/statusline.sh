#!/bin/bash
# Status line: [branch |] model (effort thinking) | ↑in ↓out (ctx%) cost | duration | limits: 5h / 7d
input=$(cat)

eval "$(echo "$input" | jq -r '
  @sh "cwd=\(.workspace.current_dir // .cwd // ".")",
  @sh "model=\(.model.display_name // "?")",
  @sh "effort=\(.effort.level // "")",
  @sh "thinking=\(if .thinking.enabled == true then "thinking" else "" end)",
  @sh "tin=\(.context_window.total_input_tokens // 0)",
  @sh "tout=\(.context_window.total_output_tokens // 0)",
  @sh "ctx=\(.context_window.used_percentage // "")",
  @sh "cost=\(.cost.total_cost_usd // "")",
  @sh "dur=\(.cost.total_duration_ms // "")",
  @sh "five=\(.rate_limits.five_hour.used_percentage // "")",
  @sh "week=\(.rate_limits.seven_day.used_percentage // "")",
  @sh "five_reset=\(.rate_limits.five_hour.resets_at // "")",
  @sh "week_reset=\(.rate_limits.seven_day.resets_at // "")"
')"

# Show reset time for limits at or above this percentage
LIMIT_WARN_PCT=80

# Model with optional effort/thinking details
details="$effort${effort:+${thinking:+ }}$thinking"
branch=$(git --no-optional-locks -C "$cwd" branch --show-current 2>/dev/null)
out="${branch:+$branch | }$model"
[ -n "$details" ] && out="$out ($details)"

# Tokens and context usage
fmt_tokens() {
  awk -v n="$1" 'BEGIN {
    if (n >= 1000000) printf "%.1fM", n / 1000000
    else if (n >= 1000) printf "%.1fk", n / 1000
    else printf "%d", n
  }'
}
out="$out | ↑$(fmt_tokens "$tin") ↓$(fmt_tokens "$tout")"
[ -n "$ctx" ] && out="$out ($(printf '%.0f' "$ctx")%)"
[ -n "$cost" ] && out="$out \$$(printf '%.2f' "$cost")"

# Duration
fmt_dur() {
  local s=$1
  if [ "$s" -ge 86400 ]; then
    echo "$((s / 86400))d$(((s % 86400) / 3600))h"
  elif [ "$s" -ge 3600 ]; then
    echo "$((s / 3600))h$(((s % 3600) / 60))m"
  elif [ "$s" -ge 60 ]; then
    echo "$((s / 60))m$((s % 60))s"
  else
    echo "${s}s"
  fi
}
[ -n "$dur" ] && out="$out | $(fmt_dur $((${dur%.*} / 1000)))"

# Rate limits, with reset time when usage is high
fmt_limit() {
  local pct=$1 reset=$2 r
  [ -z "$pct" ] && { printf -- '-'; return; }
  pct=$(printf '%.0f' "$pct")
  printf '%s%%' "$pct"
  [ "$pct" -ge "$LIMIT_WARN_PCT" ] && [ -n "$reset" ] || return
  # resets_at may be epoch seconds or an ISO 8601 string
  [[ $reset =~ ^[0-9]+$ ]] || reset=$(date -d "$reset" +%s 2>/dev/null) || return
  r=$((reset - $(date +%s)))
  [ "$r" -lt 0 ] && r=0
  printf ' (resets in %s)' "$(fmt_dur "$r")"
}
out="$out | limits: $(fmt_limit "$five" "$five_reset") / $(fmt_limit "$week" "$week_reset")"

printf '%s' "$out"
