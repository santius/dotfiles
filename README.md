# Dotfiles

Personal macOS/Linux Mint bootstrap and dotfile collection for terminal-first development. The repo bundles shell customisations, language toolchains, GUI apps, and opinionated defaults into a single reproducible setup.

## Highlights

- ⚡️ **Fast Zsh environment** – tuned `.zshrc` with lazy SDKMAN, caching, delta-powered diffs, and rich aliases/functions under `config/shell/zsh_custom/`.
- 🔧 **One-touch bootstrap** – `install.sh` backs up existing config, symlinks dotfiles, installs Homebrew packages, and optionally syncs fonts.
- 🍎 **OS defaults** – `install.sh` can auto-detect macOS or Linux Mint and apply curated desktop defaults; root wrappers call scripts under `scripts/defaults/`.
- 🍺 **Curated toolchain** – `config/brew/Brewfile` covers CLI essentials (git, delta, direnv), language runtimes (node, python, go, rust), GUI apps, fonts, and MAS apps.
- 🧩 **Extensible structure** – scripts for aliases, exports, functions, cron jobs, and custom binaries live under a clear directory layout you can extend.

## Requirements

- macOS 13+ with Command Line Tools (`xcode-select --install`)
- Homebrew (`/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`)
- Git + GPG (for signed commits)

## Quick Start

```bash
# 1. Clone
 git clone https://github.com/your-username/dotfiles.git ~/dev/dotfiles
 cd ~/dev/dotfiles

# 2. Inspect / tweak configs (optional)
 nvim config/home/.zshrc

# 3. Run the bootstrap (prompts before major steps)
 ./install.sh --fonts      # add --fonts to copy fonts into /Library/Fonts

# 4. Apply OS defaults manually if desired
 ./set-defaults.sh my-macbook
 ./set-defaults-linux-mint.sh my-linux-mint-box

# 5. Verify Homebrew bundle
 brew bundle check --file config/brew/Brewfile --verbose
```

> **Tip:** rerun `install.sh` when the repo changes; it is idempotent and keeps 5 rotating backups in `~/.dotfiles_backups/`.

## Repository Layout

| Path | Purpose |
| --- | --- |
| `install.sh` | Main installer (backups, symlinks, executes scripts, configures Neovim/fonts) |
| `set-defaults.sh` | Wrapper for the macOS defaults script |
| `set-defaults-linux-mint.sh` | Wrapper for the Linux Mint defaults script |
| `config/brew/Brewfile` | Homebrew Bundle: taps, formulae, casks, MAS entries |
| `config/home/` | Files mirrored into `$HOME` (zsh, git, ssh, Neovim, kitty, etc.) |
| `config/shell/zsh_custom/` | Modular zsh customisations (`aliases.zsh`, `exports.zsh`, `functions.zsh`) |
| `config/git/` | Git extras (e.g. commit templates) |
| `scripts/defaults/` | OS-specific defaults implementations |
| `scripts/installers/` | Shared bash helpers used by the installer |
| `scripts/shared/` | Shared shell libraries such as logging |
| `scripts/` | Support scripts run during install (e.g. plugin bootstrap) |
| `assets/fonts/` | Fonts copied when installing with `--fonts` |
| `assets/keyboards/` | Keyboard layout exports and hardware-related assets |

## Customisation

- **Secrets** – drop environment secrets in `~/.secrets`; `config/shell/zsh_custom/exports.zsh` sources it first.
- **Work profiles** – add per-directory git config via `~/.gitconfig-work` (see `[includeIf]` in the gitconfig).
- **Extra Zsh modules** – add `.zsh` files under `config/shell/zsh_custom/`; they autoload after Oh My Zsh.
- **Install scripts** – any executable in `scripts/` runs automatically during `install.sh`.

### Adding `.config` files

For a new app config that should live at `~/.config/pepito/config`, add the source file under:

```text
config/home/.config/pepito/config
```

Then add the relative path to `config_files` in `scripts/installers/config_dotfiles.sh`:

```bash
local config_files=(
    bat/config
    btop/btop.conf
    karabiner/karabiner.json
    neofetch/config.conf
    pepito/config
)
```

On the next `./install.sh`, the installer creates the source file if missing and links:

```text
~/.config/pepito/config -> config/home/.config/pepito/config
```

If an app should be managed as a whole directory instead of individual files, add its directory name to `config_dirs` instead.

## Maintenance

- Update Brew packages: `brew bundle install --file config/brew/Brewfile` then `brew bundle cleanup --file config/brew/Brewfile` to prune extras.
- Refresh plugins / zsh: `omz update && exec zsh`.
- Regenerate Neovim plugins: `nvim --headless +PlugInstall +qall`.
- Rotate backups manually: `ls ~/.dotfiles_backups` (installer keeps the last five snapshots).

## Troubleshooting

| Issue | Fix |
| --- | --- |
| `nvim PlugInstall` complains about `$GIT_DIR` | Installer now unsets `GIT_DIR` before headless plug installs; rerun `install.sh`. |
| `logger.sh` readonly variable errors | Fixed by guarding color exports; rerun script or source `logger.sh` once. |
| `brew bundle` missing taps | Run `brew tap homebrew/bundle homebrew/cask homebrew/cask-fonts homebrew/services` then retry with `--file config/brew/Brewfile`. |
| `set-defaults` commands denied | Some `systemsetup`/`pmset` calls require relaxed Secure Boot; warnings are safe to ignore. |

## License

This repo is MIT licensed. Fork, remix, and share improvements via PRs or issues.
