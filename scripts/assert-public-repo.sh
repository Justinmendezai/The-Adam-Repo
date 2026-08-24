#!/usr/bin/env bash
# Fail if this checkout is the private factory clone.
# Run before publishing first-run / README / Codex bootstrap copy.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
origin="$(git -C "$ROOT" remote get-url origin 2>/dev/null || true)"

if printf '%s' "$origin" | grep -q 'slowcoder360/adam'; then
  echo "WRONG REPO: origin is slowcoder360/adam (private factory)." >&2
  echo "Public first-run lives in https://github.com/Justinmendezai/The-Adam-Repo" >&2
  exit 1
fi

if ! printf '%s' "$origin" | grep -q 'Justinmendezai/The-Adam-Repo'; then
  echo "warning: origin is not Justinmendezai/The-Adam-Repo ($origin)" >&2
  echo "A fork is OK. Do not treat slowcoder360/adam as the public product." >&2
fi

echo "OK: $origin"
