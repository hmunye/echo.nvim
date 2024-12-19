local M = {}

local state = {
    opts = {},
    bufnr = -1,
    winid = -1,
}

function M.init_prompt_input_opts(opts)
    state.opts = opts or {}

    -- Set default values for prompt opts
    state.opts.model = state.opts.model or ""
    state.opts.model_options = state.opts.model_options or {}
    state.opts.prompt = state.opts.prompt or {}
    state.opts.start_insert_mode = state.opts.start_insert_mode or true
    state.opts.parent_window = state.opts.parent_window or {}
end

function M.create_prompt_input()
    if not vim.api.nvim_buf_is_valid(state.bufnr) then
        state.bufnr = vim.api.nvim_create_buf(false, true)
    end

    local height = math.floor(
        vim.api.nvim_win_get_height(state.opts.parent_window.winid) * 0.05
    )

    -- Default to bottom
    local row = 48

    if state.opts.prompt.prompt_position == "top" then
        row = 0
    end

    state.winid = vim.api.nvim_open_win(state.bufnr, true, {
        relative = "editor", -- Floating window relative to the entire editor
        width = state.opts.parent_window.width,
        height = height,
        row = row,
        col = state.opts.parent_window.col,
        border = state.opts.prompt.border or "rounded",
        style = "minimal",
        title = state.opts.prompt.title or state.opts.model,
        title_pos = "left",
    })

    vim.api.nvim_set_option_value("wrap", true, { win = state.winid })
    -- vim.api.nvim_set_option_value("cursorline", true, { win = state.winid })
    vim.api.nvim_set_option_value("modifiable", true, { buf = state.bufnr })

    if state.opts.prompt.start_insert_mode then
        vim.cmd([[startinsert]])
    end

    return { bufnr = state.bufnr, winid = state.winid }
end

local function get_input()
    if not vim.api.nvim_buf_is_valid(state.bufnr) then
        return ""
    end

    local lines = vim.api.nvim_buf_get_lines(state.bufnr, 0, -1, false)

    return lines[1] or ""
end

vim.api.nvim_create_user_command("EchoSubmitPrompt", function()
    print(vim.inspect(get_input()))
end, {})

return M
