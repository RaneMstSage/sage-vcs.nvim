-- lua/sage-vcs/init.lua
local M = {}

-- Plugin configuration defaults
M.config = {
    debug = false,
}

function M.setup(opts)
    M.config = vim.tbl_deep_extend('force', M.config, opts or {})

    -- Set up SVN commands
    require('sage-vcs.commands').setup()
end

return M
