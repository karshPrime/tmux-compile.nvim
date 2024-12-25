
-- TermActions.Lua

local Helpers = require( "tmux-compile.TermHelpers" )
local Env = require( "tmux-compile.Env" )

local Actions = {}

--
-- run command in a new or existing tmux window
function Actions.new_window( aCmd, aWindowTitle, aErrorName )
    if not aCmd then
        local lExtension = Env.get_file_extension()
        print( "Error: " .. aErrorName .. " command not found for ." .. lExtension )

        return 1
    end

end


--
-- run command in an overlay pane
function Actions.overlay( aCmd, aSleepDuration, aWidth, aHeight, aErrorName )
    if not aCmd then
        local lExtension = Env.get_file_extension()
        print( "Error: " .. aErrorName .. " command not found for ." .. lExtension )

        return 1
    end

end

--
-- run command in same window on a new pane
function Actions.split_window( aCmd, aSide, aWidth, aHeight, aNewPane, aErrorName )
    if not aCmd then
        local lExtension = Env.get_file_extension()
        print( "Error: " .. aErrorName .. " command not found for ." .. lExtension )

        return 1
    end

    if aSide == "h" then
        local lCurrentWin = vim.api.nvim_get_current_win()
        vim.cmd( "wincmd l" )
        local lMovedWin = vim.api.nvim_get_current_win()

        if lCurrentWin == lMovedWin or aNewPane then
            lWidth = math.floor( vim.api.nvim_win_get_width(0) * aWidth / 100 )
            vim.cmd( lWidth .. "vs" )
        end
    else
        local lCurrentWin = vim.api.nvim_get_current_win()
        vim.cmd( "wincmd j" )
        local lMovedWin = vim.api.nvim_get_current_win()

        if lCurrentWin == lMovedWin or aNewPane then
            lHeight = math.floor( vim.api.nvim_win_get_height(0) * aHeight / 100 )
            vim.cmd( lHeight .. " split" )
        end
    end

    vim.cmd( "term " .. aCmd )
    vim.wo.scrolloff = 0
    vim.wo.sidescrolloff = 0
    vim.wo.number = false
    vim.wo.relativenumber = false

    vim.cmd( "wincmd p" )
end

return Actions

