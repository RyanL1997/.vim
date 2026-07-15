#!/usr/bin/env bash
set -euo pipefail

# Restore IntelliJ IDEA settings from this repo into the live config dir.
#
# IntelliJ must be CLOSED while restoring, otherwise it will overwrite these
# files on exit. This copies settings over the existing config in place
# (existing files are overwritten, not merged) — back up the config dir first
# if you want a safety net.

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="$REPO_DIR/settings"

if [ ! -d "$SRC" ]; then
  echo "Error: no backup found at $SRC (run backup.sh first)" >&2
  exit 1
fi

case "$OSTYPE" in
  darwin*) JB_ROOT="$HOME/Library/Application Support/JetBrains" ;;
  linux*)  JB_ROOT="$HOME/.config/JetBrains" ;;
  *) echo "Error: unsupported platform: $OSTYPE" >&2; exit 1 ;;
esac

DEST="$(ls -d "$JB_ROOT"/IntelliJIdea* 2>/dev/null | sort -V | tail -1 || true)"
if [ -z "$DEST" ]; then
  echo "Error: no IntelliJ config dir under $JB_ROOT to restore into." >&2
  echo "Launch IntelliJ once to create it, then re-run." >&2
  exit 1
fi

echo "Restoring into: $DEST"
echo "Make sure IntelliJ is CLOSED. Press Enter to continue, Ctrl-C to abort."
read -r _

cp -R "$SRC/options" "$DEST/" 2>/dev/null || true
for sub in colors codestyles keymaps templates fileTemplates inspection quicklists; do
  [ -d "$SRC/$sub" ] && cp -R "$SRC/$sub" "$DEST/"
done
[ -f "$SRC/idea.vmoptions" ]       && cp "$SRC/idea.vmoptions" "$DEST/"
[ -f "$SRC/disabled_plugins.txt" ] && cp "$SRC/disabled_plugins.txt" "$DEST/"

echo ""
echo "Done. Third-party plugins are NOT auto-installed — reinstall from:"
echo "  $SRC/plugins.txt"
echo "Then launch IntelliJ."
