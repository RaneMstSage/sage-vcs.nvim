# sage-vcs.nvim
A unified VCS interface for Neovim with fugitive-style commands.

## Features
- **Auto VCS Detection**: Automatically detects Git, SVN, or other VCS systems
- **Unfied Interfaces**: Same keybindings work accross different VCS types
- **SVN Support**: Full-featured SVN operations with fugitive-like commands
- **Sage Namespace**: Personal branding and custom workflow integration

## Status
- **In Development** - SVN backend implementation in progress

## Instalation
```lua
-- Using lazy.nvim
{
    'RaneMstSage/sage-vcs.nvim',
    config = function()
        require('sage-vcs').setup()
    end
}
```

## Quick Start
```vim
:SageStatus     " Show VCS Status (Works with Git/SVN)
:SageCommit     " Interactive commit interface
:SageDiff       " View CHanges
```
---
Part of the Sage development ecosystem

