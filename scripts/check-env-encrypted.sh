#!/usr/bin/env bash
# env/ এর কোনো ফাইল encrypted না থাকলে থামায় (git commit আর make setup/env এর আগে চলে)
set -euo pipefail
cd "$(git rev-parse --show-toplevel 2>/dev/null || echo "$(dirname "$0")/..")"
bad=0
for f in env/*.env; do
  [ -e "$f" ] || continue
  if ! head -n1 "$f" | grep -q '^\$ANSIBLE_VAULT'; then
    echo "❌ $f encrypted না। চালাও: make encrypt"; bad=1
  fi
done
exit $bad
