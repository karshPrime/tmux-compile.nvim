
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

end


return Actions

