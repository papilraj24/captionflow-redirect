#!/bin/bash
# Runs the Cloudflare quick tunnel and auto-updates the GitHub Pages redirect
# page whenever a new tunnel URL is assigned (e.g. after a restart).
LOG=/tmp/captionflow-tunnel.log
UPDATE_SCRIPT="$(cd "$(dirname "$0")" && pwd)/update-redirect.sh"

: > "$LOG"
/opt/homebrew/bin/cloudflared tunnel --url http://localhost:5001 >> "$LOG" 2>&1 &
CF_PID=$!

# Wait for the URL to appear in the log, then push the redirect update.
for i in $(seq 1 30); do
  URL=$(grep -o 'https://[a-z-]*\.trycloudflare\.com' "$LOG" | head -1)
  if [ -n "$URL" ]; then
    "$UPDATE_SCRIPT" "$URL" >> "$LOG" 2>&1
    break
  fi
  sleep 1
done

wait "$CF_PID"
