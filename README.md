# tmux-compile.nvim

Neovim plugin designed to simplify the process of compiling and running projects
within tmux panes or windows. Supports multiple programming languages by
allowing customisation of build and run commands.

Also supports running [lazygit](https://github.com/jesseduffield/lazygit) from
within current Neovim session on an overlay terminal.

![preview](.media/screenshot.gif)
<br>
[editor theme above](https://github.com/karshPrime/tokyoburn.nvim)

## Install & Setup

Install using your favorite plugin manager. For example, using
[lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{ 'karshPrime/tmux-compile.nvim', event = 'VeryLazy' },
```

And setup it with:

```lua
require('tmux-compile').setup({
    -- Overriding Default Configurations. [OPTIONAL]
    save_session = false,             -- Save file before action (:wall)
    build_run_window_title = "build", -- Tmux window name for Build/Run
    ---- same window pane
    new_pane_everytime = false,       -- Use existing side panes for action, when false
    side_width_percent = 50,          -- Side pane width percentage
    bottom_height_percent = 30,       -- Bottom pane height percentage
    ---- overlay window
    overlay_width_percent = 80,       -- Overlay width percentage
    overlay_height_percent = 80,      -- Overlay height percentage
    overlay_sleep = 1,                -- Pause before overlay autoclose; seconds
                                      -- By default it sets value to -1,
                                      -- indicating not to autoclose overlay

    -- Languages' Run and Build actions.  [REQUIRED]
    build_run_config = {
        {
            extension = {'c', 'cpp', 'h'},
            build = 'make',
            run   = 'make run',
            debug = 'lldb',
        },
        {
            extension = {'rs'},
            build = 'cargo build',
            run   = 'cargo run',
            -- not all properties are required for all extensions
        },
        {
            extension = {'go'},
            run = 'go run .',
            -- Run would work for golang
            -- but Build and Debug will return errors informing configs are
            -- missing
        }
    },

    -- Directory override config. [OPTIONAL]
    -- Set actions for a specific directory (per project basis)
    project_override_config = {
        {
            project_base_dir = '/absolute/path/to/project',
            build = 'make',
            run   = 'make run',
            debug = 'lldb',
        },
        {
            project_base_dir = '~/Projects/ESP32/',
            build = 'idf.py build',
            run   = 'idf.py flash /dev/cu.usbmodem1101'
            -- Only build will work for this path
        }
    }


    -- Defining project overrides locally.
    -- Along with the previously defined 'project_override_config' it is also possible to define build/run/debug actions
    -- locally inside the project working directory.
    -- The plugin will look for a configuratino file called 'tmux-compile.lua' inside the following directories
    -- RELATIVE to the vim current owrking directory:
    -- ./.nvim/
    -- ./nvim/
    -- ./
    -- example tmux-compile.lua file

    return {
        build = "make",
        run = "make run"
    }

    -- IMPORTANT: configuration precedence
    -- When starting, this plugin will load and apply the build/run/debug commands in the following order

    -- 1. tmux-compile.lua
    -- 2. project_override_config
    -- 3. build_run_config

    -- If there is no tmux-compile.lua file defined in the current working directory, the plugin will load the commands from the 'project_override_config' table inside the main config. If that is also not defined for the current working directory, then the plugin will default to the commands defined by the file extension of the current buffer
})

```

## Keybinds

Create keybindings for any command by adding the following to Neovim config:

```lua
vim.keymap.set('n', 'KEYBIND', 'COMMAND<CR>', {silent=true})
```

Example: to set F5 to compile and run current project in an overlay terminal
window-

```lua
vim.keymap.set('n','<F5>', ':TMUXcompile Run<CR>', {silent=true})
```

### List of all supported commands

| Action / Purpose                                        | Command                |
| ------------------------------------------------------- | ---------------------- |
| Compile program in an overlay terminal window           | `:TMUXcompile Make`    |
| Compile program in a new tmux window                    | `:TMUXcompile MakeBG`  |
| Compile program in a new pane next to current nvim pane | `:TMUXcompile MakeV`   |
| Compile program in a new pane bellow current nvim pane  | `:TMUXcompile MakeH`   |
| Run program in an overlay terminal window               | `:TMUXcompile Run`     |
| Run program in a tmux new window                        | `:TMUXcompile RunBG`   |
| Run program in a new pane next to current nvim pane     | `:TMUXcompile RunV`    |
| Run program in a new pane bellow current nvim pane      | `:TMUXcompile RunH`    |
| Start debugger in an overlay terminal window            | `:TMUXcompile Debug`   |
| Start debugger in a tmux new window                     | `:TMUXcompile DebugBG` |
| Start debugger in a new pane next to current nvim pane  | `:TMUXcompile DebugV`  |
| Start debugger in a new pane bellow current nvim pane   | `:TMUXcompile DebugH`  |
| Open lazygit in overlay                                 | `:TMUXcompile lazygit` |

\* **Run** here includes both compiling and running the program, depending on the
run command specified for the file extension.

<details>
<summary>Important Notice: Backward Compatibility Break v1 -> v2</summary>
Please note that backward compatibility is broken from Version 1 to Version 2
due to the implementation of a more robust configuration system. In the previous
version, user configuration consisted of a simple list of extensions with their
associated make and run command properties. However, with the introduction of
overlay functionality, it became necessary to add an identifier to this
previously unnamed list, resulting in incompatibility with older configurations.
<br>
Apologies for any inconvenience this may cause. From version 2, the plugin has been
designed with future-proofing in mind to ensure that such issues do not recur.
</details>
