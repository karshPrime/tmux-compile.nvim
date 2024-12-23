
-- Commands.Lua

local Actions = require( "tmux-compile.actions" )
local Helpers = require( "tmux-compile.helpers" )
local Env = require( "tmux-compile.env" )

local Commands = {}

--
-- commands dispatch
function Commands.dispatch( aOption, aConfig )
    if not Env.is_tmux_installed() then
        print( "Error: install TMUX to use the plugin" )
        return 1
    end

    if not Env.is_tmux_running() then
        print( "Error: run session in TMUX" )
        return 1
    end

    if aConfig.save_session then
        vim.cmd( ":wall" )
    end

    local lExtension = Helpers.get_file_extension()
    local lMake, lRun, lDebug = Helpers.get_commands_for_extension( lExtension, aConfig )
    local lEveryTime = aConfig.new_pane_everytime
    local lBHeight = aConfig.bottom_height_percent
    local lSWidth  = aConfig.side_width_percent
    local lOHeight = aConfig.overlay_height_percent
    local lOWidth  = aConfig.overlay_width_percent

    local lCommands = {
        Run   = function() Actions.overlay( lRun, aConfig.overlay_sleep, lOWidth, lOHeight, "Run" ) end,
        RunV  = function() Actions.split_window( lRun, "v", lSWidth, lBHeight, lEveryTime,  "Run" ) end,
        RunH  = function() Actions.split_window( lRun, "h", lSWidth, lBHeight, lEveryTime,  "Run" ) end,
        RunBG = function() Actions.new_window( lRun, aConfig.build_run_window_title, "Run" ) end,

        Make   = function() Actions.overlay( lMake, aConfig.overlay_sleep, lOWidth, lOHeight, "Make" ) end,
        MakeV  = function() Actions.split_window( lMake, "v", lSWidth, lBHeight, lEveryTime, "Make"  ) end,
        MakeH  = function() Actions.split_window( lMake, "h", lSWidth, lBHeight, lEveryTime, "Make"  ) end,
        MakeBG = function() Actions.new_window( lMake, aConfig.build_run_window_title, "Make" ) end,

        Debug   = function() Actions.overlay( lDebug, aConfig.overlay_sleep, lOWidth, lOHeight, "Debug" ) end,
        DebugV  = function() Actions.split_window( lDebug, "v", lSWidth, lBHeight, lEveryTime, "Debug"  ) end,
        DebugH  = function() Actions.split_window( lDebug, "h", lSWidth, lBHeight, lEveryTime, "Debug"  ) end,
        DebugBG = function() Actions.new_window( lDebug, aConfig.build_run_window_title, "Debug" ) end,

        lazygit = function() Actions.lazygit( lOWidth, lOHeight ) end
    }

    if lCommands[aOption] then
        lCommands[aOption]()
    else
        print( "Error: Invalid aOption." )
    end
end

return Commands

