#!/bin/bash
# Status line: model (effort thinking) | ↑in ↓out (ctx%) cost | duration | limits: 5h / 7d
input=$(cat)

eval "$(echo "$input" | jq -r '
  @sh "model=\(.model.display_name // "?")",
  @sh "effort=\(.effort.level // "")",
  @sh "thinking=\(if .thinking.enabled == true then "thinking" else "" end)",
  @sh "tin=\(.context_window.total_input_tokens // 0)",
  @sh "tout=\(.context_window.total_output_tokens // 0)",
  @sh "ctx=\(.context_window.used_percentage // "")",
  @sh "cost=\(.cost.total_cost_usd // "")",
  @sh "dur=\(.cost.total_duration_ms // "")",
  @sh "five=\(.rate_limits.five_hour.used_percentage // "")",
  @sh "week=\(.rate_limits.seven_day.used_percentage // "")"
')"

# Model with optional effort/thinking details
details="$effort${effort:+${thinking:+ }}$thinking"
out="$model"
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
if [ -n "$dur" ]; then
  s=$((${dur%.*} / 1000))
  if [ "$s" -ge 3600 ]; then
    d="$((s / 3600))h$(((s % 3600) / 60))m"
  elif [ "$s" -ge 60 ]; then
    d="$((s / 60))m$((s % 60))s"
  else
    d="${s}s"
  fi
  out="$out | $d"
fi

# Rate limits
f="-"; w="-"
[ -n "$five" ] && f="$(printf '%.0f' "$five")%"
[ -n "$week" ] && w="$(printf '%.0f' "$week")%"
out="$out | limits: $f / $w"

printf '%s' "$out"
