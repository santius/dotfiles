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

# Add more plugins here as needed

echo "Vim plugins installation complete!"