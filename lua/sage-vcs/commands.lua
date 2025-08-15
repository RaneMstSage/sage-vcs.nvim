-- lua/sage-vcs/commands.lua
local M = {}

function M.setup()
    -- Create user commands for SVN operations
    vim.api.nvim_create_user_command('SageStatus', function()
        require('sage-vcs.svn').status()
    end, { desc = ' Show SVN Status' })

    vim.api.nvim_create_user_command('SageCommit', function()
        require('sage-vcs.svn').commit()
    end, { desc = 'SVN commit interface' })

    vim.api.nvim_create_user_command('SageDiff', function()
        require('sage-vcs.svn').diff()
    end, { desc = 'Show SVN diff' })

    vim.api.nvim_create_user_command('SageLog', function()
        require('sage-vcs.svn').log()
    end, { desc = 'Show SVN log' })

    vim.api.nvim_create_user_command('SageAdd', function()
        require('sage-vcs.svn').add(opt.args)
    end, { 
            desc = 'Add files to SVN',
            nargs = '*',        -- Accept multiple arguments
            complete = 'file'   -- File completeion
        })
end

return M
