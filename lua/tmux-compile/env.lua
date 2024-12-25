
-- Env.Lua

local Env = {}

--
-- check if session is in tmux
function Env.tmux_not_running()
    return vim.env.TMUX == nil
end

--
-- get the file extension
function Env.get_file_extension()
    local lFilename = vim.api.nvim_buf_get_name( 0 )
    local lExtension = lFilename:match( "^.+(%..+)$" )

    return lExtension and lExtension:sub( 2 ) or "No Extension"
end

--
-- get build, run & debug commands based on file extension
function Env.get_commands_for_extension( aExtension, aConfig )
    for _, lConfig in ipairs( aConfig.build_run_config ) do
        if vim.tbl_contains( lConfig.extension, aExtension ) then
            return lConfig.build, lConfig.run, lConfig.debug
        end
    end

    return nil, nil, nil
end


return Env

