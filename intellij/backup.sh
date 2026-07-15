#!/usr/bin/env bash
set -euo pipefail

# Back up portable IntelliJ IDEA settings into this repo.
#
# Copies only version-controllable settings (editor, colors, code style,
# keymaps, live templates, fonts, VM options, plugin list). Machine-specific
# state, caches, telemetry, and anything containing secrets are excluded — see
# EXCLUDE below.

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEST="$REPO_DIR/settings"

# --- Locate the live IntelliJ config dir (newest version) ------------------
case "$OSTYPE" in
  darwin*) JB_ROOT="$HOME/Library/Application Support/JetBrains" ;;
  linux*)  JB_ROOT="$HOME/.config/JetBrains" ;;
  *) echo "Error: unsupported platform: $OSTYPE" >&2; exit 1 ;;
esac

SRC="$(ls -d "$JB_ROOT"/IntelliJIdea* 2>/dev/null | sort -V | tail -1 || true)"
if [ -z "$SRC" ] || [ ! -d "$SRC" ]; then
  echo "Error: no IntelliJ config found under $JB_ROOT" >&2
  exit 1
fi
echo "Source: $SRC"
echo "Dest:   $DEST"

# --- Files under options/ to NEVER back up ---------------------------------
# Sensitive (secrets / accounts / connection info) + machine-specific state +
# telemetry/feedback noise.
EXCLUDE=(
  # sensitive
  aws.xml gitlab.xml github.xml databaseSettings.xml databaseDrivers.xml
  dataSources.xml dataSources.local.xml settingsSync.xml trusted-paths.xml
  # machine-specific paths
  jdk.table.xml path.macros.xml recentProjects.xml other.xml
  # UI / session state
  window.state.xml window.layouts.xml runner.layout.xml
  # telemetry / feedback / stats
  updates.xml usage.statistics.xml dailyLocalStatistics.xml
  features.usage.statistics.xml statistics.xml actionSummary.xml
  contributorSummary.xml CommonFeedbackSurveyService.xml
  DontShowAgainFeedbackService.xml k2-feedback.xml KotlinRejectersInfoService.xml
  ProjectCreationInfoService.xml AIOnboardingPromoWindowAdvisor.xml
  pluginFreezes.xml ml.completion.xml inline.factors.completion.xml
  EventLogAllowedList.xml shownTips.xml
  # caches
  scalafmt_dynamic_resolve_cache.xml web-types-npm-loader.xml
)
excluded() { local f; for f in "${EXCLUDE[@]}"; do [ "$1" = "$f" ] && return 0; done; return 1; }

# --- Copy curated settings -------------------------------------------------
rm -rf "$DEST"
mkdir -p "$DEST/options"

shopt -s nullglob
for f in "$SRC"/options/*.xml; do
  base="$(basename "$f")"
  excluded "$base" && continue
  case "$base" in *.local.xml) continue ;; esac  # machine-local, not synced
  cp "$f" "$DEST/options/"
done

# Subdirs that are always safe to version (custom schemes / templates)
for sub in colors codestyles keymaps templates fileTemplates inspection quicklists; do
  if [ -d "$SRC/$sub" ] && [ -n "$(ls -A "$SRC/$sub" 2>/dev/null)" ]; then
    cp -R "$SRC/$sub" "$DEST/"
  fi
done

# idea.vmoptions: keep only real user JVM flags; drop the Toolbox-injected
# lines (machine-specific paths + a per-machine notification token).
if [ -f "$SRC/idea.vmoptions" ]; then
  grep -vE 'toolbox' "$SRC/idea.vmoptions" > "$DEST/idea.vmoptions" || true
  [ -s "$DEST/idea.vmoptions" ] || rm -f "$DEST/idea.vmoptions"
fi
[ -f "$SRC/disabled_plugins.txt" ] && cp "$SRC/disabled_plugins.txt" "$DEST/"

# Installed third-party plugins (names only — binaries are not committed)
if [ -d "$SRC/plugins" ]; then
  ls "$SRC/plugins" | sort > "$DEST/plugins.txt"
fi
shopt -u nullglob

# --- Secret scan: warn if anything token-like slipped through --------------
hits="$(grep -rIlE '(secret|token|password|api[_-]?key|apikey|private[_-]?key|bearer)' "$DEST" 2>/dev/null || true)"
if [ -n "$hits" ]; then
  echo ""
  echo "WARNING: possible secrets in backed-up files — review before committing:"
  echo "$hits" | sed 's/^/  /'
fi

echo ""
echo "Done. Review 'git status' / 'git diff' then commit."
