# My personal dotfiles.

## Vim

Create a symbolic link from the vimrc file within the root of the repo to
~/.vimrc and another from the vim directory within the repo root to ~/.vim.

All plugins are maintained via Vundle.

### Installation

```
git clone https://github.com/gmarik/vundle.git vim/bundle/vundle
vim +InstallBundle +qall
```

### Add new

```
vim vimrc
Bundle "some/bundle"
```

### Updating

```
vim +InstallBundle +qall
```

### Removal

```
Remove it from .vimrc
rm -fr vim/bundle/<plugin>
```

## YouCompleteMe

```
cd ~/.vim/bundle/YouCompleteMe
./install.sh --clang-completer
```
