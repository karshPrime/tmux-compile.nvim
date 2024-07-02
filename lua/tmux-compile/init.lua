
-- tmux-compile.nvim
-- Plugin to compile and run projects in panes or windows

--# INITIALISE #----------------------------------------------------------------

require('helper')
require('tmux')
require('term')

local M = {}
M.config = {
    save_session = false,
    build_run_window_title = "build",
    new_pane_everytime = false,
    side_width_percent = 50,
    bottom_height_percent = 30,
    overlay_sleep = 1,
    overlay_width_percent = 80,
    overlay_height_percent = 80,
    always_term = false,
    build_run_config = {}
}

function M.setup(config)
    for key, value in pairs(config) do
        M.config[key] = value or M.config[key]
    end
end


--# NVIM DISPATCH #-------------------------------------------------------------

-- call the appropriate function based on the option
function M.dispatch(option)
    if tmux_not_found() or tmux_not_running() or M.config.always_term then
        local overlay = term_overlay;
        local split_window = term_overlay;
        local new_window = term_new_window;
    else
        local overlay = tmux_overlay;
        local split_window = tmux_split_window;
        local new_window = tmux_new_window;
    end

    if M.config.save_session then
        vim.cmd(":wall")
    end

    local extension = get_file_extension()
    local make, run, debug = get_commands_for_extension(extension)

    local commands = {
        Run = function() overlay(run, M.config.overlay_sleep, "Run") end,
        RunV = function() split_window(run, "v", "Run") end,
        RunH = function() split_window(run, "h", "Run") end,
        RunBG = function() new_window(run, "Run") end,
        Make = function() overlay(make, M.config.overlay_sleep, "Make") end,
        MakeV = function() split_window(make, "v", "Make") end,
        MakeH = function() split_window(make, "h", "Make") end,
        MakeBG = function() new_window(make, "Make") end,
        Debug = function() overlay(debug, M.config.overlay_sleep, "Debug") end,
        DebugV = function() split_window(debug, "v", "Debug") end,
        DebugH = function() split_window(debug, "h", "Debug") end,
        DebugBG = function() new_window(debug, "Debug") end,

        lazygit = function() 
            if vim.fn.executable("lazygit") == 1 then
                overlay("lazygit", 0)
            else
                print("Error: lazygit not installed.")
            end
        end,
    }

    if commands[option] then
        commands[option]()
    else
        print("Error: Invalid option.")
    end
end

-- invoke the dispatch function
vim.api.nvim_create_user_command('TMUXcompile', function(args)
    M.dispatch(args.args)
end, {
    nargs = 1,
    complete = function()
        return {
            "lazygit",
            "Run", "RunV", "RunH", "RunBG",
            "Make", "MakeV", "MakeH", "MakeBG",
            "Debug", "DebugV", "DebugH", "DebugBG"
        }
    end,
})

return M

