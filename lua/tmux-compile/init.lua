-- tmux-compile.nvim
-- Plugin to compile and run projects in tmux panes or windows

local M = {}


--# Helper #-------------------------------------------------------------------

-- Get the configuration for the current file's extension
local function get_language_config(extension)
    for _, lang_config in ipairs(M.config.languages) do
        if vim.tbl_contains(lang_config.extension, extension) then
            return lang_config
        end
    end
    return nil
end

-- Get the current file's extension
local function get_current_file_extension()
    return vim.fn.expand('%:e')
end

-- Execute a command in a new Tmux pane or window
local function tmux_execute(command, placement)
    if not vim.fn.exists('$TMUX') == 1 then
        vim.notify("Not running inside a Tmux session.", vim.log.levels.ERROR)
        return
    end

    local pane_cmd = ""
    if placement == "below" then
        pane_cmd = "split-window -v"
    elseif placement == "side" then
        pane_cmd = "split-window -h"
    elseif placement == "new_window" then
        pane_cmd = "new-window -n run"
    else
        vim.notify("Invalid placement option.", vim.log.levels.ERROR)
        return
    end

    local full_command = string.format("tmux %s '%s'", pane_cmd, command)
    vim.fn.system(full_command)
end

-- compile the current project
local function compile_project(placement)
    local extension = get_current_file_extension()
    local lang_config = get_language_config(extension)

    if lang_config then
        local build_command = lang_config.build
        tmux_execute(build_command, placement)
    else
        vim.notify("Unsupported file type: " .. extension, vim.log.levels.ERROR)
    end
end

-- compile and run the current project
local function compile_and_run_project(placement)
    local extension = get_current_file_extension()
    local lang_config = get_language_config(extension)

    if lang_config then
        local build_command = lang_config.build
        local run_command = lang_config.run
        tmux_execute(build_command .. " && " .. run_command, placement)
    else
        vim.notify("Unsupported file type: " .. extension, vim.log.levels.ERROR)
    end
end


--# Support functions for indie compile and run #------------------------------

-- compile the project in different Tmux placements
function M.compile_below()
    compile_project("below")
end

function M.compile_side()
    compile_project("side")
end

function M.compile_new_window()
    compile_project("new_window")
end

-- compile and run the project in different Tmux placements
function M.run_below()
    compile_and_run_project("below")
end

function M.run_side()
    compile_and_run_project("side")
end

function M.run_new_window()
    compile_and_run_project("new_window")
end


--# Process User Config #------------------------------------------------------

function M.setup(config)
    M.config = config
end

return M

