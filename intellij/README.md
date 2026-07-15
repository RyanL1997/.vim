# IntelliJ IDEA Settings

Version-controlled backup of portable IntelliJ IDEA settings — editor, colors,
code style, keymaps, live templates, fonts, VM options, and the installed
plugin list.

## Usage

```bash
# Save current IDE settings into the repo
./intellij/backup.sh

# Restore settings onto a new machine (close IntelliJ first)
./intellij/restore.sh
```

Both scripts auto-detect the newest `IntelliJIdea*` config dir:

- **macOS** — `~/Library/Application Support/JetBrains/`
- **Linux / WSL** — `~/.config/JetBrains/`

## What's backed up

`settings/` holds a curated subset:

- `options/*.xml` — editor, look & feel, fonts, VCS, language settings, etc.
- `colors/`, `codestyles/`, `keymaps/`, `templates/` — custom schemes & templates
- `idea.vmoptions` — JVM flags (Toolbox-injected lines stripped)
- `disabled_plugins.txt`, `plugins.txt` — plugin state / reinstall reference

## What's excluded (and why)

`backup.sh` uses an allow-by-directory + deny-by-file model so nothing
sensitive or machine-specific is committed:

- **Secrets / accounts** — `aws.xml`, `databaseSettings.xml`, `gitlab.xml`,
  `settingsSync.xml`, `trusted-paths.xml`, `idea.key` (license), and the
  per-machine `toolbox.notification.token` inside `idea.vmoptions`.
- **Machine-specific** — `jdk.table.xml`, `path.macros.xml`,
  `recentProjects.xml`, any `*.local.xml`, window/session state.
- **Telemetry / feedback / caches** — usage stats, feedback surveys,
  completion-model caches, etc.

After copying, `backup.sh` greps the result for token/password/key patterns and
warns before you commit. Plugin binaries and caches (~740 MB) are never copied —
`plugins.txt` lists names only, for manual reinstall.
