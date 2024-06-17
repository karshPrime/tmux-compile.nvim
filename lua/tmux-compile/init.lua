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
    local output = vim.fn.system("which tmux 2>/dev/null")
    return output ~= "" and not string.match(output, "tmux not found")
end

-- check if session is in tmux
local function is_tmux_running()
  local output = vim.fn.system("tmux info 2>/dev/null")
  return output ~= "" and not string.match(output, "no client running")
end


--# HELPER FUNCTIONS #----------------------------------------------------------

-- get the file extension
local function get_file_extension()
    local filename = vim.api.nvim_buf_get_name(0)
    if filename == "" then return nil end
    return filename:match("^.+(%..+)$"):sub(2)
end

-- get build and run commands based on file extension
local function get_commands_for_extension(extension)
    local fileExtension = get_file_extension()
    if fileExtension then
        for _, cfg in ipairs(M.config) do
            if vim.tbl_contains(cfg.extension, extension) then
                return cfg.build, cfg.run
            end
        end
        print("No build and run commands found for this extension")
    else
        print("No file extension found")
    end
    return nil, nil
end

-- check if a tmux window with the given name exists
local function tmux_window_exists(window_name)
    local handle = io.popen("tmux list-windows | grep -w " .. window_name)
    local result = handle:read("*a")
    handle:close()
    return result ~= ""
end


--# CALL FUNCTIONS #------------------------------------------------------------

-- function to run the command in a new or existing tmux window
function M.new_window(cmd)
    if cmd then
        local window_name = "build"

        if tmux_window_exists(window_name) then
            local cmd_head = "silent !tmux select-window -t " .. window_name
            vim.cmd(cmd_head .. " \\; send-keys '" .. cmd .. "' C-m")
        else
            local cmd_head = "silent !tmux new-window -n " .. window_name
            vim.cmd(cmd_head .. " '" .. cmd .. "; zsh'")
        end
    else
        print("No run command found for this extension")
    end
end

function M.same_window(cmd, side)
    if cmd then
        local cmd_head = "silent !tmux split-window "
        vim.cmd(cmd_head .. side .. " -v '" .. cmd .. "; exec zsh'")
    else
        print("No run command found for this extension")
    end
end


--# NVIM DISPATCH #-------------------------------------------------------------

-- call the appropriate function based on the option
function M.dispatch(option)

    -- confirm tmux is installed
    if not is_tmux_installed() then
        print("Error: install TMUX to use the plugin")
        return 1
    end

    -- check if tmux running, else print error
    if not is_tmux_running() then
        print("Error: run session in TMUX")
        return 1
    end

    local make, run = get_commands_for_extension(get_file_extension())

    if option == "RunBG" then
        M.new_window(run)
    elseif option == "RunV" then
        M.same_window(run, "-v")
    elseif option == "RunH" then
        M.same_window(run, "-h")
    elseif option == "MakeV" then
        M.same_window(make, "-v")
    elseif option == "MakeH" then
        M.same_window(make, "-h")
    elseif option == "Make" then
        M.new_window(make)
    else
        print("Invalid option. Please use one of: RunBG, RunV, RunH, Make")
    end
end

-- invoke the dispatch function
vim.api.nvim_create_user_command('TMUXcompile', function(args)
    M.dispatch(args.args)
end, {
    nargs = 1,
    complete = function(arglead, cmdline, cursorpos)
        return { "RunBG", "RunV", "RunH", "Make" }
    end,
})

return M

