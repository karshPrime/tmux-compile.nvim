
-- TMUX functions

--# CHECK ENVIRONMENT #---------------------------------------------------------

-- confirm tmux is installed
local function tmux_not_found()
    return vim.fn.executable("tmux") ~= 1
end

-- check if session is in tmux
local function is_tmux_running()
    return vim.env.TMUX == nil
end


--# HELPER FUNCTIONS #----------------------------------------------------------

-- check if a tmux window with the given name exists
local function tmux_window_exists(window_name)
    local result = vim.fn.system("tmux list-windows | grep -w " .. window_name)
    return result ~= ""
end

-- change directory if not same as project
local function change_dir(pane)
    local proj_dir = vim.fn.trim(vim.fn.system("pwd"))
    local win_dir = vim.fn.trim(vim.fn.system("tmux display -p -t " .. pane .. " '#{pane_current_path}'"))

    if (win_dir == proj_dir) or (win_dir == ("/private"..proj_dir)) then
        return ""
    end

    return "cd " .. proj_dir .. "; "
end


--# CALL FUNCTIONS #------------------------------------------------------------

-- run command in a new or existing tmux window
local function tmux_new_window(cmd, error_name)
    if not cmd then
        local extension = get_file_extension()
        print("Error: " .. error_name .. " command not found for " .. extension)
        return 1
    end

    local window_name = M.config.build_run_window_title

    if tmux_window_exists(window_name) then
        cmd = change_dir(window_name) .. cmd

        vim.fn.system("tmux selectw -t " .. window_name .. " \\; send-keys '" .. cmd .. "' C-m")
    else
        vim.fn.system("tmux neww -n " .. window_name .. " '" .. cmd .. "; zsh'")
    end
end


-- run command in an overlay pane
local function tmux_overlay(cmd, sleep_duration, error_name)
    if not cmd then
        local extension = get_file_extension()
        print("Error: " .. error_name .. " command not found for " .. extension)
        return 1
    end

    local proj_dir = vim.fn.trim(vim.fn.system("pwd"))
    local cmd_head = "tmux display-popup -E -d" .. proj_dir

    local dimensions = " -w " .. M.config.overlay_width_percent .. "\\% -h " .. M.config.overlay_height_percent .. "\\% '"

    local sleep = "; sleep " .. sleep_duration .. "'"

    vim.fn.system(cmd_head .. dimensions .. cmd .. sleep)
end


-- run command in same window on a new pane
local function tmux_split_window(cmd, side, error_name)
    if not cmd then
        local extension = get_file_extension()
        print("Error: " .. error_name .. " command not found for " .. extension)
        return 1
    end

    local direction_lookup = {
        v = "-D",
        h = "-R"
    }

    local length_percentage = {
        v = M.config.bottom_height_percent,
        h = M.config.side_width_percent
    }

    local current_pane = vim.fn.system("tmux display -p '#{pane_id}'")
    vim.fn.system("tmux selectp " .. direction_lookup[side])
    local moved_pane = vim.fn.system("tmux display -p '#{pane_id}'")

    if (vim.trim(current_pane) == vim.trim(moved_pane) or M.config.new_pane_everytime) then
        local parameters = side .. " -l " .. length_percentage[side] .. "%"
        vim.fn.system("tmux splitw -" .. parameters .. " '" .. cmd .. "; zsh'")
    else
        cmd = change_dir(vim.trim(moved_pane)) .. cmd
        vim.fn.system("tmux send -t " .. vim.trim(moved_pane) .. " '" .. cmd .. "' C-m")
    end
end

