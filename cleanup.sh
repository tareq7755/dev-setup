#!/usr/bin/env bash
# Free disk space by clearing developer caches, build output and leftover junk.
# Everything removed here is regenerated automatically when needed.
#
#   ./cleanup.sh          dry run: show what would be removed and how big it is
#   ./cleanup.sh --run    actually remove it
#
# Never touches: Downloads, Documents, Local Documents, source code, git repos.

# Re-launch in full bash if started via `sh cleanup.sh` (POSIX mode lacks `< <(...)`).
if [ -z "${BASH_VERSION:-}" ] || shopt -qo posix 2>/dev/null; then
  exec /bin/bash "$0" "$@"
fi
set -uo pipefail

RUN=false
[ "${1:-}" = "--run" ] && RUN=true
REPOS="$HOME/Repos"

bold() { printf '\n\033[1m== %s\033[0m\n' "$1"; }
size() { du -sh "$1" 2>/dev/null | cut -f1; }

# Remove a path (file or dir) if it exists.
remove() {
  local p="$1"
  [ -e "$p" ] || return 0
  printf '  %-8s %s\n' "$(size "$p")" "${p/#$HOME/~}"
  $RUN && rm -rf "$p"
}

# Empty a directory's contents but keep the directory itself.
empty_dir() {
  local d="$1"
  [ -d "$d" ] || return 0
  printf '  %-8s %s/*\n' "$(size "$d")" "${d/#$HOME/~}"
  $RUN && find "$d" -mindepth 1 -maxdepth 1 -exec rm -rf {} + 2>/dev/null
}

# Remove a directory only if it is empty (ignores .DS_Store).
remove_if_empty() {
  local d="$1"
  [ -d "$d" ] || return 0
  rm -f "$d/.DS_Store" 2>/dev/null || true
  if [ -z "$(ls -A "$d" 2>/dev/null)" ]; then
    printf '  %-8s %s (empty)\n' "0B" "${d/#$HOME/~}"
    $RUN && rmdir "$d"
  else
    printf '  skip     %s (not empty)\n' "${d/#$HOME/~}"
  fi
}

# Run a command only when the tool exists.
run_cmd() {
  local tool="$1"; shift
  command -v "$tool" >/dev/null || return 0
  echo "  \$ $*"
  $RUN && "$@" >/dev/null 2>&1
}

$RUN || echo "DRY RUN — nothing will be deleted. Re-run with --run to apply."
echo "Free before: $(df -h / | awk 'NR==2{print $4}')"

if $RUN && pgrep -xq "Xcode|Simulator"; then
  echo "Xcode or Simulator is running — quit them first."; exit 1
fi

bold "Xcode"
# Keep the newest DeviceSupport folder (your current phone's iOS) so connecting
# it doesn't trigger the slow "Copying shared cache symbols" step.
DS="$HOME/Library/Developer/Xcode/iOS DeviceSupport"
if [ -d "$DS" ]; then
  newest="$(ls -t "$DS" 2>/dev/null | head -1)"
  [ -n "$newest" ] && echo "  keep     ~/Library/Developer/Xcode/iOS DeviceSupport/$newest"
  while IFS= read -r d; do remove "$DS/$d"; done < <(ls -t "$DS" 2>/dev/null | tail -n +2)
fi
empty_dir "$HOME/Library/Developer/Xcode/DerivedData"
printf '  %-8s %s\n' "$(size "$HOME/Library/Developer/CoreSimulator")" "~/Library/Developer/CoreSimulator (unavailable sims only)"
run_cmd xcrun xcrun simctl delete unavailable

bold "System caches"
empty_dir "$HOME/Library/Caches"

bold "Package manager caches"
printf '  %-8s %s\n' "$(size "$HOME/.npm")" "~/.npm"
run_cmd npm npm cache clean --force
printf '  %-8s %s\n' "$(size "$HOME/go/pkg/mod")" "~/go/pkg/mod"
run_cmd go go clean -modcache
remove "$HOME/.gradle/caches"
remove "$HOME/.m2/repository"
remove "$HOME/.pub-cache/hosted"
echo "  (Homebrew old downloads)"
run_cmd brew brew cleanup --prune=all

bold "Build output & node_modules in ~/Repos"
if [ -d "$REPOS" ]; then
  # node_modules anywhere (pruned so nested ones aren't listed twice)
  while IFS= read -r d; do remove "$d"; done < <(
    find "$REPOS" -name node_modules -type d -prune 2>/dev/null)
  # Flutter/Dart projects
  while IFS= read -r f; do
    p="$(dirname "$f")"; remove "$p/build"; remove "$p/.dart_tool"
  done < <(find "$REPOS" -maxdepth 3 -name pubspec.yaml -not -path '*/node_modules/*' 2>/dev/null)
  # Maven projects
  while IFS= read -r f; do remove "$(dirname "$f")/target"; done < <(
    find "$REPOS" -maxdepth 3 -name pom.xml -not -path '*/node_modules/*' 2>/dev/null)
  # Next.js projects
  while IFS= read -r f; do remove "$(dirname "$f")/.next"; done < <(
    find "$REPOS" -maxdepth 3 -name package.json -not -path '*/node_modules/*' 2>/dev/null)
fi

bold "Leftover folders"
for d in db_backup docker IdeaSnapshots Postman jianying_data_sync_server__10 test; do
  remove_if_empty "$HOME/$d"
done
remove_if_empty "$REPOS/test"
remove "$REPOS/.idea"

bold ".DS_Store files in ~/Repos"
n=$(find "$REPOS" -name .DS_Store -type f 2>/dev/null | wc -l | tr -d ' ')
echo "  $n files"
$RUN && find "$REPOS" -name .DS_Store -type f -delete 2>/dev/null

echo
if $RUN; then
  echo "Done. Free after: $(df -h / | awk 'NR==2{print $4}')"
else
  echo "Dry run complete. Run ./cleanup.sh --run to delete."
fi
