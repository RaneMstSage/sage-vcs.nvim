-- lua/sage-vcs/ui.lua
local M = {}

-- helper function to create a new buffer with content
local function create_buffer(title, content, filetype)
    -- Create new buffer
    local buf = vim.api.nvim_create_buf(false, true)

    -- Set buffer content
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, content)

    -- Set buffer options
    vim.api.nvim_set_option_value('modifiable', false, { buf = buf })
    vim.api.nvim_set_option_value('buftype', 'nofile', { buf = buf })
    vim.api.nvim_buf_set_name(buf, title)

    if filetype then
        vim.api.nvim_set_option_value('filetype', filetype, { buf = buf })
    end

    -- Open buffer in split
    vim.cmd('split')
    vim.api.nvim_win_set_buf(0, buf)

    -- Set window options
    vim.api.nvim_set_option_value('number', false, { win = 0 })
    vim.api.nvim_set_option_value('relativenumber', false, { win = 0 })

    -- Add basic keymap to close buffer
    vim.api.nvim_buf_set_keymap(buf, 'n', 'q', '<cmd>bdelete<CR>', { noremap = true, silent = true })

    return buf
end

-- Show SVN status output
function M.show_status(data)
    local lines = {}

    -- Get SVN info for header
    local svn_info = require('sage-vcs.svn').get_svn_info()

    -- Header Section
    if svn_info.relative_url then
        local branch = svn_info.relative_url:gsub('^%^/', '') -- Remove ^/ prefix
        table.insert(lines, 'Branch: ' .. branch)
    end

    if svn_info.root then
        table.insert(lines, 'Root: ' .. svn_info.root)
    end

    table.insert(lines, 'Help: h?')
    table.insert(lines, '')

    -- Group files by status
    local modified = {}
    local added = {}
    local deleted = {}
    local untracked = {}
    local conflicted = {}

    for _, line in ipairs(data) do
        if line ~= '' then
            local status = line:sub(1,1)
            local file = line:sub(9):gsub('^%s+', '') -- Remove leading spaces

            if status == 'M' then
                table.insert(modified, file)
            elseif status == 'A' then
                table.insert(added, file)
            elseif status == 'D' then
                table.insert(deleted, file)
            elseif status == '?' then
                table.insert(untracked, file)
            elseif status == 'C' then
                table.insert(conflicted, file)
            end
        end
    end

    -- Display grouped sections
    if #modified > 0 then
        table.insert(lines, 'Modified (' .. #modified .. ')')
        for _, file in ipairs(modified) do
            table.insert(lines, 'M ' .. file)
        end
        table.insert(lines, '')
    end

    if #added > 0 then
        table.insert(lines, 'Added (' .. #added .. ')')
        for _, file in ipairs(added) do
            table.insert(lines, 'A ' .. file)
        end
        table.insert(lines, '')
    end

    if #untracked > 0 then
        table.insert(lines, 'Untracked (' .. #untracked .. ')')
        for _, file in ipairs(untracked) do
            table.insert(lines, '? ' .. file)
        end
        table.insert(lines, '')
    end

    if #lines == 3 then -- Only header
        table.insert(lines, 'No changes in working directory')
    end

    create_buffer('SVN Status', lines)
end

-- Show SVN diff output
function M.show_diff(data)
    local lines = {}
    for _, line in ipairs(data) do
        if line ~= '' then
            table.insert(lines, line)
        end
    end

    create_buffer('SVN Diff', lines, 'diff')
end

-- Show SVN log output
function M.show_log(data)
    local lines = {}
    for _, line in ipairs(data) do
        if line ~= '' then
            table.insert(lines, line)
        end
    end

    create_buffer('SVN Log', lines)
end

return M
