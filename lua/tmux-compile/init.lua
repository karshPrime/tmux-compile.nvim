-- init.lua

local Commands = require("tmux-compile.commands")
local Helpers = require("tmux-compile.helpers")

local M = {}
M.config = {
    save_session = false,
    build_run_window_title = "build",
    new_pane_everytime = false,
    side_width_percent = 50,
    bottom_height_percent = 30,
    overlay_sleep = -1,
    overlay_width_percent = 80,
    overlay_height_percent = 80,
    build_run_config = {},
    notify_missing_project_config = false,
}

function M.setup(aConfig)
    for key, value in pairs(aConfig) do
        M.config[key] = value or M.config[key]
    end

    local lLocalConfig = Helpers.search_project_defined_override_config(M.config["notify_missing_project_config"])
    if lLocalConfig ~= nil then
        M.config["project_override_config"] = lLocalConfig
        M.config["override_config_from_project"] = true
    else
        M.config["override_config_from_project"] = false
    end
end

-- nvim command integration
vim.api.nvim_create_user_command("TMUXcompile", function(args)
    Commands.dispatch(args.args, M.config)
end, {
    nargs = 1,
    complete = function()
        return {
            "yazi",
            "lazygit",
            "Run",
            "RunV",
            "RunH",
            "RunBG",
            "Make",
            "MakeV",
            "MakeH",
            "MakeBG",
            "Debug",
            "DebugV",
            "DebugH",
            "DebugBG",
        }
    end,
})

return M
