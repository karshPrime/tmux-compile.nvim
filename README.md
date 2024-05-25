# tmux-compile.nvim

Neovim plugin designed to simplify the process of compiling and running projects
within tmux panes or windows. Supports multiple programming languages by
allowing customisation of build and run commands.


## Installation

Install using your favorite plugin manager. For example, using
[lazy.nvim](https://github.com/folke/lazy.nvim):
```lua
use {
  'lazy.tmux-compile.nvim',
  config = function()
    require('tmux-compile').setup({
        languages = {
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
            -- Add more language configurations as needed
        }
    })
  end
}
```

## Keybinds

```lua
-- compile and run
vim.keymap.set('n', '<leader>rd',
    ':lua require("tmux-compile.nvim").run_below()<CR>',
    { noremap = true, silent = true })

vim.keymap.set('n', '<leader>rs',
    ':lua require("tmux-compile.nvim").run_side()<CR>',
    { noremap = true, silent = true })

vim.keymap.set('n', '<leader>rn',
    ':lua require("tmux-compile.nvim").run_new_window()<CR>',
    { noremap = true, silent = true })

-- just compile 
vim.keymap.set('n', '<leader>rcd',
    ':lua require("tmux-compile.nvim").compile_below()<CR>',
    { noremap = true, silent = true })

vim.keymap.set('n', '<leader>rcs',
    ':lua require("tmux-compile.nvim").compile_side()<CR>',
    { noremap = true, silent = true })

vim.keymap.set('n', '<leader>rcn',
    ':lua require("tmux-compile.nvim").compile_new_window()<CR>',
    { noremap = true, silent = true })
```
