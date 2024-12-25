
-- Commands.Lua

local Env = require( "tmux-compile.env" )
local Commands = {}

--
-- commands dispatch
function Commands.dispatch( aOption, aConfig )
    if Env.tmux_not_running() or aConfig.always_term then
        Actions = require( "tmux-compile.TermActions" )
    else
        Actions = require( "tmux-compile.TmuxActions" )
    end

    if aConfig.save_session then
        vim.cmd( ":wall" )
    end

    local lExtension = Env.get_file_extension()
    local lMake, lRun, lDebug = Env.get_commands_for_extension( lExtension, aConfig )

    local commands = {
        Run   = { command = lRun,   title = "Run"   },
        Make  = { command = lMake,  title = "Make"  },
        Debug = { command = lDebug, title = "Debug" }
    }

    local function execute_command( cmd, lOrientation, lBackground )
        local lCommandInfo = commands[cmd]
        if not lCommandInfo then
            print("Error: Invalid aOption.")
            return
        end

        local action = lBackground and Actions.new_window or Actions.overlay
        if lOrientation then
            action = Actions.split_window
        end

        if lBackground then
            -- new window
            action(
                lCommandInfo.command,
                aConfig.build_run_window_title,
                lCommandInfo.title
            )
        elseif lOrientation then
            -- split pane
            action(
                lCommandInfo.command,
                lOrientation,
                aConfig.side_width_percent,
                aConfig.bottom_height_percent,
                aConfig.new_pane_everytime,
                lCommandInfo.title
            )
        else
            -- overlay
            action(
                lCommandInfo.command, 
                aConfig.overlay_sleep,
                aConfig.overlay_width_percent,
                aConfig.overlay_height_percent,
                lCommandInfo.title
            )
        end
    end

    if aOption == "lazygit" then
        if vim.fn.executable( "lazygit" ) == 1 then
            Actions.overlay(
                "lazygit", 0, aConfig.overlay_width_percent, aConfig.overlay_height_percent, ""
            )
        else
            print( "Error: lazygit not installed." )
        end

    else
        local lOrientation = nil
        local lBackground = false

        if aOption:sub(-1) == "V" then
            lOrientation = "v"
            aOption = aOption:sub(1, -2)

        elseif aOption:sub(-1) == "H" then
            lOrientation = "h"
            aOption = aOption:sub(1, -2)

        elseif aOption:sub(-2) == "BG" then
            lBackground = true
            aOption = aOption:sub(1, -3)
        end

        execute_command( aOption, lOrientation, lBackground )
    end
end

return Commands

