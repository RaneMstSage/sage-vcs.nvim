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

    -- Add basic keymap to close buffer
    vim.api.nvim_buf_set_keymap(buf, 'n', 'q' '<cmd>close<CR>', { noremap = true, silent = true })

    return buf
end

-- Show SVN status output
function M.show_status(data)
    local lines = {}
    for _, line in ipairs(data) do
        if line ~= '' then
            table.insert(lines, line)
        end
    end

    if #lines == 0 then
        vim.notify('No changes in working directory', vim.log.levels.INFO)
        return
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
