local M = {}

local state = {
    opts = {},
    bufnr = -1,
    winid = -1,
}

function M.init_prompt_input_opts(opts)
    state.opts = opts or {}

    -- Set default values for model, window, and parent_window
    state.opts.model = state.opts.model or ""
    state.opts.window = state.opts.window or {}
    state.opts.parent_window = state.opts.parent_window or {}
end

function M.create_prompt_input()
    if not vim.api.nvim_buf_is_valid(state.bufnr) then
        state.bufnr = vim.api.nvim_create_buf(false, true)
    end

    local height = math.floor(
        vim.api.nvim_win_get_height(state.opts.parent_window.winid) * 0.05
    )

    state.winid = vim.api.nvim_open_win(state.bufnr, true, {
        relative = "editor", -- Floating window relative to the entire editor
        width = state.opts.parent_window.width,
        height = height,
        row = height * 25,
        col = state.opts.parent_window.col,
        border = "rounded",
        style = "minimal",
        title = state.opts.model,
        title_pos = "left",
    })

    vim.api.nvim_set_option_value("wrap", true, { win = state.winid })
    -- vim.api.nvim_set_option_value("cursorline", true, { win = state.winid })
    vim.api.nvim_set_option_value("modifiable", true, { buf = state.bufnr })

    M.setup_keymaps()

    return { winid = state.winid }
end

function M.submit_prompt_input(input)
    print(vim.inspect(input))
end

function M.setup_keymaps()
    local function get_input()
        if not vim.api.nvim_buf_is_valid(state.bufnr) then
            return ""
        end

        local lines = vim.api.nvim_buf_get_lines(state.bufnr, 0, -1, false)

        return lines[1] or ""
    end

    vim.keymap.set("n", "<CR>", function()
        M.submit_prompt_input(get_input())
    end, { buffer = state.bufnr, noremap = true, silent = true })

    vim.keymap.set("i", "<CR>", function()
        M.submit_prompt_input(get_input())
    end, { buffer = state.bufnr, noremap = true, silent = true })
end

return M
