# setup

Personal macOS config. Real files live here; the usual locations are symlinks to them.

| File | Linked from |
|---|---|
| `zsh/.zshrc` | `~/.zshrc` |
| `ghostty/config` | `~/.config/ghostty/config` |
| `starship/starship.toml` | `~/.config/starship.toml` |
| `Brewfile` | Homebrew packages and apps |

## New machine

```sh
git clone <this repo> ~/Repos/setup
cd ~/Repos/setup
./install.sh --brew   # links configs + installs everything in Brewfile
```

Run `./install.sh` without `--brew` to only (re)create the links.

## Updating

- Configs: edit as usual (via `~/.zshrc` etc.) — changes land here, then commit.
- Brewfile after installing/removing something:
  ```sh
  brew bundle dump --file=~/Repos/setup/Brewfile --force
  ```

## Cleanup

```sh
./cleanup.sh         # dry run: lists what would be removed + sizes
./cleanup.sh --run   # delete caches, build output, node_modules, empty leftovers
```

Only removes things that regenerate (Xcode/simulator data, package caches, build dirs). Never touches Downloads, Documents or source.

## Notes

- Ghostty: reload config with `Cmd+Shift+,`.
- Starship only shows folder, git, command duration, jobs and prompt char — all language/cloud modules are hidden via `format`.
- zsh-autosuggestions is installed but intentionally disabled in `.zshrc`.
