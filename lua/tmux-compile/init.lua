-- tmux-compile.nvim
-- Plugin to compile and run projects in tmux panes or windows

--# INITIALISE #----------------------------------------------------------------

local M = {}
M.config = {}

function M.setup(config)
    M.config = config
end

--# CHECK ENVIRONMENT #---------------------------------------------------------

-- confirm tmux is installed
local function is_tmux_installed()
    return vim.fn.executable("tmux") == 1
end

-- check if session is in tmux
local function is_tmux_running()
    return vim.env.TMUX ~= nil
end

-- create terminal buffer if it doesn't already exists
local function terminal_buffer()
    local bufnr = vim.fn.bufnr('terminal')
    if bufnr == -1 then
        vim.cmd(":terminal<CR>:file term<CR>:setlocal nonu norelativenumber<CR>:norm 4jA<CR>")
    else
        vim.cmd(":buffer terminal<CR>")
    end
end


--# HELPER FUNCTIONS #----------------------------------------------------------

-- get the file extension
local function get_file_extension()
    local filename = vim.api.nvim_buf_get_name(0)
    return filename:match("^.+(%..+)$"):sub(2)
end

-- get build and run commands based on file extension
local function get_commands_for_extension(extension)
    if extension then
        for _, cfg in ipairs(M.config) do
            if vim.tbl_contains(cfg.extension, extension) then
                return cfg.build, cfg.run
            end
        end
        print("Error: No build and run commands found for this extension")
    else
        print("Error: No file extension found")
    end
    return nil, nil
end

-- check if a tmux window with the given name exists
local function tmux_window_exists(window_name)
    local result = vim.fn.system("tmux list-windows | grep -w " .. window_name)
    return result ~= ""
end


--# CALL FUNCTIONS #------------------------------------------------------------

-- run command in a new or existing tmux window
local function tmux_window(cmd)
    if not is_tmux_running() then
        print("Error: run session in TMUX")
        return 1
    end
    if not is_tmux_installed() then
        print("Error: install TMUX to use the plugin")
        return 1
    end

    local window_name = "build"

    if tmux_window_exists(window_name) then
        local proj_dir = vim.fn.trim(vim.fn.system("pwd"))
        local win_dir = vim.fn.trim(vim.fn.system("tmux display -p -t " .. window_name .. " '#{pane_current_path}'"))

        if win_dir ~= proj_dir then
            cmd = "cd " .. proj_dir .. "; " .. cmd
        end

        local cmd_head = "silent !tmux select-window -t " .. window_name
        vim.cmd(cmd_head .. " \\; send-keys '" .. cmd .. "' C-m")
    else
        local cmd_head = "silent !tmux new-window -n " .. window_name
        vim.cmd(cmd_head .. " '" .. cmd .. "; zsh'")
    end
end

-- run command on top of current vim session
local function override_window(cmd)
    if cmd then
        terminal_buffer()
        vim.cmd("silent !" cmd .. "<CR>")
    else
        print("Error: No run command found for this extension")
    end
end

-- run command in a new vim pane
local function vim_pane(cmd, side)
    if cmd then
        vim.cmd(side)
        terminal_buffer()
        vim.cmd("silent !" .. cmd .. "<CR>")
    else
        print("Error: No run command found for this extension")
    end
end


--# NVIM DISPATCH #-------------------------------------------------------------

-- call the appropriate function based on the option
function M.dispatch(option)
    local extension = get_file_extension()
    local make, run = get_commands_for_extension(extension)

    if option == "Make" then
        override_window(make)
    elseif option == "Run" then
        override_window(run)
    elseif option == "RunV" then
        vim_pane(run, ":vsplit")
    elseif option == "RunH" then
        vim_pane(run, ":split")
    elseif option == "MakeV" then
        vim_pane(make, ":vsplit")
    elseif option == "MakeH" then
        vim_pane(make, ":split")
    elseif option == "MakeBG" then
        tmux_window(make)
    elseif option == "RunBG" then
        tmux_window(run)
    else
        print("Error: Invalid Option. Try: Make, Run, RunV, RunH, MakeBG, RunBG")
    end
end

-- invoke the dispatch function
vim.api.nvim_create_user_command('TMUXcompile', function(args)
    M.dispatch(args.args)
end, {
    nargs = 1,
    complete = function()
        return { "Make", "Run", "RunV", "RunH", "MakeBG", "RunBG" }
    end,
})

return M

