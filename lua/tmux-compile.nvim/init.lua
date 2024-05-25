-- tmux-compile.nvim
-- Plugin to compile and run projects in tmux panes or windows

local M = {}


--# Helpers #------------------------------------------------------------------

-- Detect if in a tmux session
local function in_tmux()
    return os.getenv("TMUX") ~= nil
end

-- Detect project language
local function detect_language()
    local files = vim.fn.readdir(vim.fn.getcwd())
    for _, file in ipairs(files) do
        if file:match("%.c$") or file:match("%.cpp$") or file:match("%.h$") then
            return "c_cpp"

        elseif file:match("%.go$") then
            return "go"

        elseif file:match("%.rs$") then
            return "rust"

        end
    end
    return nil
end


--# Compile Commands #---------------------------------------------------------

-- Compile and/or run the project in tmux
local function tmux_execute(command, new_pane)
    if not in_tmux() then
        print("Not in a tmux session.")
        return
    end

    local pane_cmd = new_pane == "below" and "split-window -v" or "split-window -h"
    if new_pane == "window" then
        pane_cmd = "new-window -n run"
    end

    os.execute(string.format("tmux %s '%s'", pane_cmd, command))
end

-- Just compile the project                        **** ADD LANGUAGES HERE ****
local function compile_project()
    local lang = detect_language()
    if lang == "go" then
        return "go build $(find . -type f -iname 'main.go')"

    elseif lang == "rust" then
        return "cargo build"

    elseif lang == "c_cpp" then
        return "make"

    else
        print("Unsupported project type.")
        return nil
    end
end


-- Compile and run the project                     **** ADD LANGUAGES HERE ****

local function compile_and_run_project()
    local lang = detect_language()
    if lang == "go" then
        return "go run $(find . -type f -iname 'main.go')"

    elseif lang == "rust" then
        return "cargo run"

    elseif lang == "c_cpp" then
        return "make run"

    else
        print("Unsupported project type.")
        return nil
    end
end


--# nvim Commands #------------------------------------------------------------

function M.run_below()
    local cmd = compile_and_run_project()
    if cmd then
        tmux_execute(cmd, "below")
    end
end

function M.run_side()
    local cmd = compile_and_run_project()
    if cmd then
        tmux_execute(cmd, "side")
    end
end

function M.run_new_window()
    local cmd = compile_and_run_project()
    if cmd then
        tmux_execute(cmd, "window")
    end
end

function M.compile_below()
    local cmd = compile_project()
    if cmd then
        tmux_execute(cmd, "below")
    end
end

function M.compile_side()
    local cmd = compile_project()
    if cmd then
        tmux_execute(cmd, "side")
    end
end

function M.compile_new_window()
    local cmd = compile_project()
    if cmd then
        tmux_execute(cmd, "window")
    end
end

return M

