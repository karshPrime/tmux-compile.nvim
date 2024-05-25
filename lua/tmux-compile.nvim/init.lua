-- tmux-compile.nvim
-- Plugin to compile and run projects in tmux panes or windows

local M = {}


--# Helper #-------------------------------------------------------------------

local function get_language_config(extension)
    for _, lang_config in ipairs(M.config.languages) do
        if vim.tbl_contains(lang_config.extension, extension) then
            return lang_config
        end
    end
    return nil
end

local function get_current_file_extension()
    return vim.fn.expand('%:e')
end


--# Helper #-------------------------------------------------------------------

local function tmux_execute(command, placement)
    local pane_cmd = ""
    if placement == "below" then
        pane_cmd = "split-window -v"

    elseif placement == "side" then
        pane_cmd = "split-window -h"

    elseif placement == "new_window" then
        pane_cmd = "new-window -n run"

    else
        return
    end

    local full_command = string.format("tmux %s '%s'", pane_cmd, command)
    vim.cmd(full_command)
end

local function compile_project(placement)
    local extension = get_current_file_extension()
    local lang_config = get_language_config(extension)

    if lang_config then
        local build_command = lang_config.build
        tmux_execute(build_command, placement)
    else
        vim.notify("Unsupported file type.")
    end
end

local function compile_and_run_project(placement)
    local extension = get_current_file_extension()
    local lang_config = get_language_config(extension)

    if lang_config then
        local build_command = lang_config.build
        local run_command = lang_config.run
        tmux_execute(build_command .. " && " .. run_command, placement)
    else
        vim.notify("Unsupported file type.")
    end
end


--# Support functions for indie compile and run #------------------------------

function M.compile_below()
    compile_project("below")
end

function M.compile_side()
    compile_project("side")
end

function M.compile_new_window()
    compile_project("new_window")
end

function M.run_below()
    compile_and_run_project("below")
end

function M.run_side()
    compile_and_run_project("side")
end

function M.run_new_window()
    compile_and_run_project("new_window")
end

function M.setup(config)
    M.config = config
end


--# Export functions for use in keybindings #----------------------------------

M.compile_project = compile_project
M.compile_and_run_project = compile_and_run_project

return M

