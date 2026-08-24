#!/usr/bin/env bash
# Install Adam skill FOLDERS into a coding-agent skill dir.
# Never flatten: each skill must remain <dest>/<name>/SKILL.md
# (flattening makes every skill look like "skill.md").
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
MODE="${1:-}"
DEST="${2:-}"

usage() {
  echo "usage: $0 cursor|codex|codex-legacy|claude [dest-dir]" >&2
  echo "  cursor        → ~/.cursor/skills" >&2
  echo "  codex         → ~/.agents/skills" >&2
  echo "  codex-legacy  → ~/.codex/skills" >&2
  echo "  claude        → ~/.claude/skills" >&2
  exit 1
}

case "$MODE" in
  cursor) DEST="${DEST:-$HOME/.cursor/skills}" ;;
  codex) DEST="${DEST:-$HOME/.agents/skills}" ;;
  codex-legacy) DEST="${DEST:-$HOME/.codex/skills}" ;;
  claude) DEST="${DEST:-$HOME/.claude/skills}" ;;
  *) usage ;;
esac

origin="$(git -C "$ROOT" remote get-url origin 2>/dev/null || true)"
if printf '%s' "$origin" | grep -q 'slowcoder360/adam'; then
  echo "warning: this clone is the private factory (slowcoder360/adam)." >&2
  echo "Public install URL is https://github.com/Justinmendezai/The-Adam-Repo" >&2
fi

mkdir -p "$DEST"
count=0
for d in "$ROOT/skills"/*/; do
  name="$(basename "$d")"
  # Replace a previous install of this skill only; leave unrelated skills alone.
  rm -rf "$DEST/$name"
  cp -R "$d" "$DEST/$name"
  count=$((count + 1))
done

echo "Installed $count skill folders → $DEST"
echo "Each skill is $DEST/<name>/SKILL.md — do not copy SKILL.md files into one directory."
