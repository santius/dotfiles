# Dotfiles Repository

This repository contains my personal configuration files (dotfiles) for setting up and customizing a development environment. It includes settings for Oh My Zsh, Kitty terminal, Vim, macOS defaults, and more.

## Table of Contents

- [Dotfiles Repository](#dotfiles-repository)
  - [Table of Contents](#table-of-contents)
  - [Overview](#overview)
  - [Dotfiles Included](#dotfiles-included)
    - [Oh My Zsh](#oh-my-zsh)
    - [Kitty](#kitty)
    - [Zsh Custom](#zsh-custom)
    - [Vim](#vim)
    - [macOS Defaults](#macos-defaults)
    - [Brewfile](#brewfile)
  - [Usage](#usage)
  - [Installation](#installation)
  - [License](#license)

---

## Overview

Dotfiles allow you to customize your development environment to increase productivity and efficiency. This repository makes it easy to set up or restore a personalized configuration on a new machine.

## Dotfiles Included

### Oh My Zsh
- **Files**: `.zshrc`, `zsh_custom/`
- **Description**:
  - `.zshrc` configures the Zsh shell, including custom aliases, functions, and theme settings.
  - `zsh_custom/` contains additional customizations for Oh My Zsh plugins and themes.

### Kitty
- **Files**: `kitty/`
- **Description**: Configuration for the Kitty terminal emulator, optimized for productivity with custom themes and key bindings.

### Zsh Custom
- **Files**: `zsh_custom/`
- **Description**: Includes additional aliases and customizations to streamline command-line usage and boost productivity.

### Vim
- **Files**: `.vimrc`
- **Description**: Config file for Vim with customizations such as syntax highlighting, custom mappings, and plugins for an enhanced editing experience.

### macOS Defaults
- **Files**: `set-defaults.sh`
- **Description**: A script to apply various macOS defaults, optimizing the user experience and improving performance by adjusting system and application settings.

### Brewfile
- **Files**: `Brewfile`
- **Description**: A Homebrew file listing essential packages and applications for setup on macOS, making it easy to install or restore required tools.

## Usage

1. **Clone the repository:**
   ```bash
   git clone https://github.com/your-username/dotfiles.git
   cd dotfiles
   ```

2. **Review the configurations:**
   - Look through the files to understand what changes will be made
   - Modify any settings to match your preferences

3. **Apply configurations:**
   ```bash
   ./install.sh
   ```

## Installation

1. **Prerequisites:**
   - macOS (recommended latest version)
   - Git
   - Command Line Tools for Xcode: `xcode-select --install`

2. **Install Homebrew:**
   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```

3. **Install dependencies:**
   ```bash
   brew bundle
   ```

4. **Set up Oh My Zsh:**
   ```bash
   sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
   ```

5. **Create symbolic links:**
   ```bash
   ./setup.sh
   ```

6. **Apply macOS defaults:**
   ```bash
   ./set-defaults.sh
   ```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

Feel free to fork this repository and customize it to your needs. If you find any issues or have suggestions for improvements, please open an issue or submit a pull request.
