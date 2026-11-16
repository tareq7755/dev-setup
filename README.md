# dev-setup

My macOS terminal setup: zsh, Ghostty, Starship and the CLI tools they use.

The config files live in this repo. Their usual locations are **symlinks** pointing here, so editing `~/.zshrc` (or any other) edits the file in this repo.

| File in repo | Linked from |
|---|---|
| `zsh/.zshrc` | `~/.zshrc` |
| `ghostty/config` | `~/.config/ghostty/config` |
| `starship/starship.toml` | `~/.config/starship.toml` |
| `Brewfile` | terminal apps and tools to install (not linked) |

---

## Set up a new Mac

### 1. Install Homebrew

Open **Terminal** and run:

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

This also installs Apple's command-line tools, which include `git`. When it finishes, run the two `eval` lines it prints under **"Next steps"** so `brew` works in this window.

### 2. Clone this repo

```sh
mkdir -p ~/Repos
git clone https://github.com/tareq7755/dev-setup.git ~/Repos/setup
cd ~/Repos/setup
```

### 3. Run the installer

```sh
./install.sh --brew
```

This will:
- link the three config files above (any existing ones are kept as `*.bak`)
- install everything in the `Brewfile`: Ghostty, the Nerd Font, Starship and the CLI tools `.zshrc` uses

It only installs. It never deletes anything.

To only recreate the links, without installing packages, run `./install.sh`.

Languages and dev tools (Go, Java, Node, Flutter, Xcode…) are not part of this setup. Install them on each machine as needed.

### 4. Set your git name and email

These are not stored in this repo. On a work laptop, use your work email.

```sh
git config --global user.name "Your Name"
git config --global user.email "you@example.com"
```

### 5. Switch to Ghostty

Quit Terminal, open **Ghostty** from Applications, and use it from now on. The font, theme and prompt are already set.

---

## Day to day

**Changing a config:** edit it in its usual place (for example `~/.zshrc`). The change lands in this repo; commit and push it.

**Adding a terminal tool:** add a `brew "name"` line to the `Brewfile` by hand, then commit. Don't use `brew bundle dump`: it would list every package on the machine, not just the terminal setup.

**Reloading changes:**
- zsh: open a new tab
- Ghostty: press `Cmd+Shift+,` (check for typos first with `ghostty +validate-config`; a bad line, like a wrong theme name, can stop the config loading)
- Starship: applies on the next prompt

---

## Free up disk space (optional)

`cleanup.sh` is separate from the installer. It clears caches and build output that regenerate on their own.

```sh
./cleanup.sh         # dry run: lists what would be deleted, with sizes
./cleanup.sh --run   # actually delete (quit Xcode and Simulator first)
```

What it clears: Xcode and simulator caches (it keeps your current phone's iOS support files), package caches, `node_modules` and build folders in `~/Repos`, and empty leftover folders.

It never touches Downloads, Documents, your source code or git history.

---

## Notes

- **Prompt:** Starship shows only the folder, git status, slow-command time and `❯`. Language versions, cloud and Docker info are hidden on purpose (see `format` in `starship.toml`).
- **Autosuggestions:** zsh shows grey "ghost text" from your history as you type. Press → or Ctrl+E to accept it.
- **Apple Silicon only:** `.zshrc` expects Homebrew at `/opt/homebrew`, which is where it installs on M-series Macs.
