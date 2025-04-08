#!/bin/bash

echo "Installing Vim themes..."

# Create necessary directories
mkdir -p ~/.vim/colors ~/.vim/bundle

# Create undo, swap and backup directories
mkdir -p ~/.vim/undo ~/.vim/swp ~/.vim/backup

# Install solarized
git clone https://github.com/altercation/vim-colors-solarized.git ~/.vim/bundle/vim-colors-solarized
ln -sf ~/.vim/bundle/vim-colors-solarized/colors/solarized.vim ~/.vim/colors/solarized.vim

# Install gruvbox
git clone https://github.com/morhetz/gruvbox.git ~/.vim/bundle/gruvbox
ln -sf ~/.vim/bundle/gruvbox/colors/gruvbox.vim ~/.vim/colors/gruvbox.vim

# Install nord
git clone https://github.com/arcticicestudio/nord-vim.git ~/.vim/bundle/nord-vim
ln -sf ~/.vim/bundle/nord-vim/colors/nord.vim ~/.vim/colors/nord.vim

# Install dracula
git clone https://github.com/dracula/vim.git ~/.vim/bundle/dracula
ln -sf ~/.vim/bundle/dracula/colors/dracula.vim ~/.vim/colors/dracula.vim

# Install onedark
git clone https://github.com/joshdick/onedark.vim.git ~/.vim/bundle/onedark.vim
ln -sf ~/.vim/bundle/onedark.vim/colors/onedark.vim ~/.vim/colors/onedark.vim

# Install palenight
git clone https://github.com/drewtempelmeyer/palenight.vim ~/.vim/bundle/palenight.vim
ln -sf ~/.vim/bundle/palenight.vim/colors/palenight.vim ~/.vim/colors/palenight.vim

# Install tender
git clone https://github.com/jacoborus/tender.vim ~/.vim/bundle/tender.vim
ln -sf ~/.vim/bundle/tender.vim/colors/tender.vim ~/.vim/colors/tender.vim

# Install catppuccin
git clone https://github.com/catppuccin/vim.git ~/.vim/bundle/catppuccin
# Link all catppuccin variants
for variant in latte frappe macchiato mocha; do
    if [ -f ~/.vim/bundle/catppuccin/colors/catppuccin-${variant}.vim ]; then
        ln -sf ~/.vim/bundle/catppuccin/colors/catppuccin-${variant}.vim ~/.vim/colors/catppuccin-${variant}.vim
    fi
done
# Also create a symlink for the generic catppuccin colorscheme if it exists
if [ -f ~/.vim/bundle/catppuccin/colors/catppuccin.vim ]; then
    ln -sf ~/.vim/bundle/catppuccin/colors/catppuccin.vim ~/.vim/colors/catppuccin.vim
fi

echo "Vim themes installation complete!"