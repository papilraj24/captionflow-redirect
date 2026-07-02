#!/bin/bash
# Updates the GitHub Pages redirect page to point at a new tunnel URL and pushes it.
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
if grep -q "$NEW_URL" index.html 2>/dev/null; then
  exit 0
fi

cat > index.html <<HTML
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8"/>
<meta http-equiv="refresh" content="0; url=$NEW_URL"/>
<title>CaptionFlow</title>
<script>window.location.replace("$NEW_URL");</script>
</head>
<body>
<p>Redirecting to <a href="$NEW_URL">CaptionFlow</a>…</p>
</body>
</html>
HTML

git add index.html
git commit -q -m "Update redirect target to $NEW_URL"
git push -q
echo "$(date '+%Y-%m-%d %H:%M:%S') Redirect updated -> $NEW_URL"
