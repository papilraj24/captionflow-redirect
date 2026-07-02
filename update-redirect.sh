#!/bin/bash
# Updates current-url.txt with the new tunnel URL and pushes it. index.html
# itself never changes — it's a static page that fetches current-url.txt at
# load time via JS, so browser/CDN caching of index.html can no longer cause
# a stale redirect. Only current-url.txt needs to be freshly fetched each
# time, and it's read from raw.githubusercontent.com (not the Pages CDN,
# which lags several seconds to minutes behind a push).
# Usage: update-redirect.sh <new-tunnel-url>
set -e

NEW_URL="$1"
if [ -z "$NEW_URL" ]; then
  echo "Usage: $0 <new-tunnel-url>" >&2
  exit 1
fi

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$REPO_DIR"

# Skip if already pointing at this URL — avoids empty commits on every tunnel log tick.
if [ -f current-url.txt ] && grep -q "$NEW_URL" current-url.txt; then
  exit 0
fi

echo -n "$NEW_URL" > current-url.txt

git add current-url.txt
git commit -q -m "Update tunnel target to $NEW_URL"
git push -q
echo "$(date '+%Y-%m-%d %H:%M:%S') Redirect updated -> $NEW_URL"
