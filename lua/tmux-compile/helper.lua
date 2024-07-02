
-- get the file extension
local function get_file_extension()
    local filename = vim.api.nvim_buf_get_name(0)
    return filename:match("^.+(%..+)$"):sub(2)
end


-- get build, run & debug commands based on file extension
local function get_commands_for_extension(extension)
    for _, cfg in ipairs(M.config.build_run_config) do
        if vim.tbl_contains(cfg.extension, extension) then
            return cfg.build, cfg.run, cfg.debug
        end
    end
    print("Error: No build and run commands found for this extension")
    return nil, nil, nil
end

