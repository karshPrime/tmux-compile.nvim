# tmux-compile.nvim

Neovim plugin designed to simplify the process of compiling and running projects
within tmux panes or windows. Supports multiple programming languages by
allowing customisation of build and run commands.


## Installation

Install using your favorite plugin manager. For example, using
[lazy.nvim](https://github.com/folke/lazy.nvim):
```lua
{  'karshPrime/tmux-compile.nvim', event = 'VeryLazy', config = function()
    require('tmux-compile').setup({
        {
            extension = {'c', 'cpp', 'h'},
            build = 'make',
            run = 'make run',
        },
        {
            extension = {'rs'},
            build = 'cargo build',
            run = 'cargo run',
        },
    })
    end 
},
```

## Keybinds

```lua
vim.keymap.set('n', 'v<F5>', ':TMUXcompile RunV<CR>',
    { noremap = true, silent = true })

vim.keymap.set('n', 'h<F5>', ':TMUXcompile RunH<CR>',
    { noremap = true, silent = true })

vim.keymap.set('n', '<F5>', ':TMUXcompile RunBG<CR>',
    { noremap = true, silent = true })

-- just compile 
vim.keymap.set('n', '<leader><F5>', ':TMUXcompile Make<CR>',
    { noremap = true, silent = true })

```
