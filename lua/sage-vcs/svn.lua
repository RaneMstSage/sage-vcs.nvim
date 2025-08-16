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

-- Find SVN root by walking up directory tree
local function find_svn_root(start_path)
    local current = start_path or vim.fn.expan('%:p:h')
    local max_depth = 20 -- Safety limit
    local depth = 0

    while current ~= '/' and current ~= '' and depth < max_depth do
        if vim.fn.isdirectory(current .. '/.svn') == 1 then
            return current
        end

        local parent = vim.fn.fnamemodify(current, ':h')
        if parent == current then   -- Hit filesystem root
            break
        end

        current = parent
        depth = depth + 1
    end

    return nil -- No SVN found
end

-- Show Status
function M.status()
    local svn_info = M.get_svn_info()
    if not svn_info then
        vim.notify('Not in an SVN working directory', vim.log.levels.ERROR)
        return
    end

    -- Change to SVN root before running command
    local old_cwd = vim.fn.getcwd()
    vim.cmd('cd ' .. svn_info.working_copy_root)

    run_svn_command({ 'status' }, function (exit_code, data)
        vim.cmd('cd ' .. old_cwd)   -- restore original directory
        if exit_code == 0 and data then
            require('sage-vcs.ui').show_status(data)
        end
    end)
end

-- Get SVN repository info
function M.get_svn_info()
    local current_file_dir = vim.fn.expand('%:p:h')
    local svn_root = find_svn_root(current_file_dir)

    if not svn_root then
        return nil  -- Not in SVN repository
    end

    local resuly = { working_copy_root = svn_root }

    -- Run svn info from the SVN root directory
    local handl = io.popen('cd "' .. svn_root '" && svn info 2>/dev/null')
    if handle then
        for line in handle:lines() do
            if line:match('^URL:') then
                result.url = line:match('^URL:%s*(.+)')
            elseif line:match('^Repository Root:') then
                result.root = line:match('Repository Root:%s*(.+)')
            elseif line:match('^Relative URL:') then
                result.relative_url = line:match('^Relative URL:%s*(.+)')
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
