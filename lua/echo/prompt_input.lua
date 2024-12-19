local M = {}

local state = {
    opts = {},
    bufnr = -1,
    winid = -1,
}

local function get_input()
    if not vim.api.nvim_buf_is_valid(state.bufnr) then
        return ""
    end

    return vim.api.nvim_buf_get_lines(state.bufnr, 0, -1, false)[1] or ""
end

function M.init_prompt_input_opts(opts)
    state.opts = opts or {}

    -- Set default values for prompt opts
    state.opts.model = state.opts.model or ""
    state.opts.model_options = state.opts.model_options or {}
    state.opts.prompt = state.opts.prompt or {}
    state.opts.start_insert_mode = state.opts.start_insert_mode or true
    state.opts.parent_window = state.opts.parent_window or {}
    state.opts.submit_callback = state.opts.submit_callback or nil
end

function M.create_prompt_input()
    if not vim.api.nvim_buf_is_valid(state.bufnr) then
        state.bufnr = vim.api.nvim_create_buf(false, true)
    end

    local height = math.floor(
        vim.api.nvim_win_get_height(state.opts.parent_window.winid) * 0.10
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
        title_pos = state.opts.prompt.title_position or "left",
    })

    vim.api.nvim_set_option_value("wrap", true, { win = state.winid })
    -- vim.api.nvim_set_option_value("cursorline", true, { win = state.winid })
    vim.api.nvim_set_option_value("modifiable", true, { buf = state.bufnr })

    if state.opts.prompt.start_insert_mode then
        vim.cmd([[startinsert]])
    end

    return { bufnr = state.bufnr, winid = state.winid }
end

vim.api.nvim_create_user_command("EchoSubmitPrompt", function()
    local input = get_input()

    if input == "" then
        return
    end

    if state.opts.submit_callback then
        state.opts.submit_callback(input)
    end

    if vim.api.nvim_buf_is_valid(state.bufnr) then
        -- Clear the prompt after submitting
        vim.api.nvim_buf_set_lines(state.bufnr, 0, -1, false, {})
    end
end, {})

return M
