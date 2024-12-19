local Prompt = require("echo.prompt_input")

local M = {}

local state = {
    opts = {},
    prompt = {
        winid = -1,
    },
    bufnr = -1,
    winid = -1,
}

function M.init_chat_window_opts(opts)
    state.opts = opts or {}

    -- Set default values for model and window
    state.opts.model = state.opts.model or ""
    state.opts.window = state.opts.window or {}
end

function M.create_chat_window()
    local function get_window_dimensions(user_width)
        local width =
            math.floor(vim.api.nvim_win_get_width(0) * (user_width / 100))
        local height = math.floor(vim.api.nvim_win_get_height(0) * 0.90)

        return width, height
    end

    local win_width, win_height =
        get_window_dimensions(state.opts.window.width or 35)

    local col

    if state.opts.window.position == "right" then
        -- Float window will be on the right side
        col = vim.api.nvim_win_get_width(0) - win_width
    elseif state.opts.window.position == "left" then
        -- Float window will be on the left side
        col = 0
    end

    if not vim.api.nvim_buf_is_valid(state.bufnr) then
        state.bufnr = vim.api.nvim_create_buf(false, true)
    end

    state.winid = vim.api.nvim_open_win(state.bufnr, true, {
        relative = "editor", -- Floating window relative to the entire editor
        width = win_width,
        height = win_height,
        row = 0,
        col = col,
        border = "rounded",
        style = "minimal",
        title = state.opts.window.title or "ECHO",
        title_pos = "center",
    })

    vim.api.nvim_set_option_value("modifiable", false, { buf = state.bufnr })

    Prompt.init_prompt_input_opts({
        model = state.opts.model,
        window = {},
        parent_window = {
            winid = state.winid,
            width = win_width,
            col = col,
        },
    })

    local prompt = Prompt.create_prompt_input()

    state.prompt.winid = prompt.winid
end

vim.api.nvim_create_user_command("EchoChat", function()
    if not vim.api.nvim_win_is_valid(state.winid) then
        M.create_chat_window()
    else
        vim.api.nvim_win_hide(state.winid)
        vim.api.nvim_win_hide(state.prompt.winid)
    end
end, {})

return M
