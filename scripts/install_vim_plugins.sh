#!/bin/bash

echo "Installing Vim plugins..."

# Create necessary directories
mkdir -p ~/.vim/bundle

# Install NERDTree
if [ ! -d ~/.vim/bundle/nerdtree ]; then
    echo "Installing NERDTree..."
    git clone https://github.com/preservim/nerdtree.git ~/.vim/bundle/nerdtree
fi

# Install vim-surround
if [ ! -d ~/.vim/bundle/vim-surround ]; then
    echo "Installing vim-surround..."
    git clone https://github.com/tpope/vim-surround.git ~/.vim/bundle/vim-surround
fi

# Install vim-commentary
if [ ! -d ~/.vim/bundle/vim-commentary ]; then
    echo "Installing vim-commentary..."
    git clone https://github.com/tpope/vim-commentary.git ~/.vim/bundle/vim-commentary
fi

# Install vim-fugitive (Git integration)
if [ ! -d ~/.vim/bundle/vim-fugitive ]; then
    echo "Installing vim-fugitive..."
    git clone https://github.com/tpope/vim-fugitive.git ~/.vim/bundle/vim-fugitive
fi

# Install vim-airline (status bar)
if [ ! -d ~/.vim/bundle/vim-airline ]; then
    echo "Installing vim-airline..."
    git clone https://github.com/vim-airline/vim-airline ~/.vim/bundle/vim-airline
    git clone https://github.com/vim-airline/vim-airline-themes ~/.vim/bundle/vim-airline-themes
fi

# Reinstall auto-pairs
rm -rf ~/.vim/bundle/auto-pairs
git clone https://github.com/jiangmiao/auto-pairs.git ~/.vim/bundle/auto-pairs

# Install vim-gitgutter (shows git diff in the gutter)
if [ ! -d ~/.vim/bundle/vim-gitgutter ]; then
    echo "Installing vim-gitgutter..."
    git clone https://github.com/airblade/vim-gitgutter.git ~/.vim/bundle/vim-gitgutter
fi

# Install vim-polyglot (language pack)
if [ ! -d ~/.vim/bundle/vim-polyglot ]; then
    echo "Installing vim-polyglot..."
    git clone https://github.com/sheerun/vim-polyglot.git ~/.vim/bundle/vim-polyglot
fi

# Install fzf.vim (fuzzy finder)
if [ ! -d ~/.vim/bundle/fzf.vim ]; then
    echo "Installing fzf.vim..."
    git clone https://github.com/junegunn/fzf.vim.git ~/.vim/bundle/fzf.vim
fi

# Install vim-multiple-cursors (multiple selections)
if [ ! -d ~/.vim/bundle/vim-multiple-cursors ]; then
    echo "Installing vim-multiple-cursors..."
    git clone https://github.com/terryma/vim-multiple-cursors.git ~/.vim/bundle/vim-multiple-cursors
fi

# Install vim-easymotion (faster navigation)
if [ ! -d ~/.vim/bundle/vim-easymotion ]; then
    echo "Installing vim-easymotion..."
    git clone https://github.com/easymotion/vim-easymotion.git ~/.vim/bundle/vim-easymotion
fi

# Install vim-indent-guides (visual indentation guides)
if [ ! -d ~/.vim/bundle/vim-indent-guides ]; then
    echo "Installing vim-indent-guides..."
    git clone https://github.com/nathanaelkane/vim-indent-guides.git ~/.vim/bundle/vim-indent-guides
fi

# Install vim-smooth-scroll (smooth scrolling)
if [ ! -d ~/.vim/bundle/vim-smooth-scroll ]; then
    echo "Installing vim-smooth-scroll..."
    git clone https://github.com/terryma/vim-smooth-scroll.git ~/.vim/bundle/vim-smooth-scroll
fi

# Install vim-css-color (color preview)
if [ ! -d ~/.vim/bundle/vim-css-color ]; then
    echo "Installing vim-css-color..."
    git clone https://github.com/ap/vim-css-color.git ~/.vim/bundle/vim-css-color
fi

# Install vim-startify (fancy start screen)
if [ ! -d ~/.vim/bundle/vim-startify ]; then
    echo "Installing vim-startify..."
    git clone https://github.com/mhinz/vim-startify.git ~/.vim/bundle/vim-startify
fi

# Install minimap.vim (code outline view)
if [ ! -d ~/.vim/bundle/minimap.vim ]; then
    echo "Installing minimap.vim..."
    git clone https://github.com/wfxr/minimap.vim.git ~/.vim/bundle/minimap.vim

    # Check if code-minimap is installed
    if ! command -v code-minimap &> /dev/null; then
        echo "Installing code-minimap dependency..."
        if command -v brew &> /dev/null; then
            brew install code-minimap
        else
            echo "Please install code-minimap: https://github.com/wfxr/code-minimap"
        fi
    fi
fi

# Install vim-devicons (file icons)
if [ ! -d ~/.vim/bundle/vim-devicons ]; then
    echo "Installing vim-devicons..."
    git clone https://github.com/ryanoasis/vim-devicons.git ~/.vim/bundle/vim-devicons

    # Check if Nerd Fonts are installed
    echo "NOTE: vim-devicons requires a Nerd Font to be installed and configured in your terminal"
    echo "You have font-jetbrains-mono-nerd-font installed in your Brewfile, please make sure it's set in your terminal"
fi

# Install vim-cool (auto disable search highlight)
if [ ! -d ~/.vim/bundle/vim-cool ]; then
    echo "Installing vim-cool..."
    git clone https://github.com/romainl/vim-cool.git ~/.vim/bundle/vim-cool
fi

# Install vim-flog (git branch viewer)
if [ ! -d ~/.vim/bundle/vim-flog ]; then
    echo "Installing vim-flog..."
    git clone https://github.com/rbong/vim-flog.git ~/.vim/bundle/vim-flog
    # vim-flog depends on vim-fugitive, which should already be installed
fi

# Add more plugins here as needed

echo "Vim plugins installation complete!"