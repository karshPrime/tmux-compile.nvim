
-- Helpers.Lua

local Helpers = {}

--
-- check if a tmux window with the given name exists
function Helpers.tmux_window_exists( aWindowName )
    local Result = vim.fn.system( "tmux list-windows | grep -w " .. aWindowName )

    return Result ~= ""
end

--
-- change directory if not same as project
function Helpers.change_dir( aPane )
    local lProjectDir = vim.fn.trim(
        vim.fn.system("git rev-parse --show-toplevel 2>/dev/null || pwd")
    )
    print(lProjectDir)

    local lWindowDir = vim.fn.trim(
        vim.fn.system( "tmux display -p -t " .. aPane .. " '#{pane_current_path}'" )
    )

    if lWindowDir == lProjectDir or lWindowDir == ( "/private" .. lProjectDir ) then
        return ""
    end

    return "cd " .. lProjectDir .. "; "
end


return Helpers

