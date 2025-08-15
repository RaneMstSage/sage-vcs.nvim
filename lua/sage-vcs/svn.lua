-- lua/sage-vcs/svn.lua
local M = {}

-- Helper function to run SVN commands
local function run_svn_command(args, callback)
    local cmd = { 'svn' }
    vim.list_extend(cmd, args)

    vim.fn.jobstart(cmd, {
        stdout_buffered = true,
        stderr_buffered = true,
        on_exit = function (_, exit_code)
            if callback then
                callback(exit_code)
            end
        end,
        on_stdout = function (_, data)
            if callback then
                callback(0, data)
            end
        end,
        on_stderr = function (_, data)
            if #data > 0 and data[1] ~= '' then
                vim.notify('SVN Error: ' .. table.concat(data, '\n'), vim.log.levels.ERROR)
            end
        end
    })
end

-- Show Status
function M.status()
    run_svn_command({ 'status' }, function (exit_code, data)
        if exit_code == 0 and data then
            require('sage-vcs.ui').show_status(data)
        end
    end)
end

-- Get SVN repository info
function M.get_svn_info()
    local result = {}

    -- Run svn info synchonously for now (we need the data immediately)
    local handle = io.popen('svn info 2>/dev/null')
    if handle then
        for line in handle:lines() do
            if line:match('^URL:') then
                result.url = line:match('^URL:%s*(.+)')
            elseif line:match('^Repository Root:') then
                result.root = line:match('^Repository Root:%s*(.+)')
            elseif line:match('^Relative URL:') then
                result.relative_url = line:match('^Relative URL:%s*(.+)')
            elseif line:match('^Working Copy Root Path:') then
                result.working_copy_root = line:match('^Working Copy Root Path:%s*(.+)')
            end
        end
        handle:close()
    end

    return result
end

-- Show SVN diff
function M.diff()
    run_svn_command({ 'diff' }, function(exit_code, data)
        if exit_code == 0 and data then
            require('sage-vcs.ui').show_diff(data)
        end
    end)
end

-- Add files to SVN
function M.add(files)
    if not files or files == '' then
        files = vim.fn.expand('%')  -- Current file if no args
    end

    run_svn_command({ 'add', files }, function (exit_code)
        if exit_code == 0 then
            vim.notify('Added to SVN: ' .. files, vim.log.levels.INFO)
        end
    end)
end

-- SVN commit interface
function M.commit()
    vim.ui.input({ prompt = 'Commit message: ' }, function (message)
        if message and message ~= '' then
            run_svn_command({ 'commit', '-m', message }, function (exit_code)
                if exit_code == 0 then
                    vim.notify('Commited successfully', vim.log.levels.INFO)
                end
            end)
        end
    end)
end

-- Show SVN log
function M.log()
    run_svn_command({ 'log', '--limit', '20' }, function (exit_code, data)
        if exit_code == 0 and data then
            require('sage-vcs.ui').show_log(data)
        end
    end)
end

return M
