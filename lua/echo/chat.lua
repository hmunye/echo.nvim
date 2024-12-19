local Prompt = require("echo.prompt_input")

local M = {}

local state = {
    opts = {},
    prompt = {
        bufnr = -1,
        winid = -1,
    },
    bufnr = -1,
    winid = -1,
}

function M.init_chat_window_opts(opts)
    state.opts = opts or {}

    -- Set default values for chat opts
    state.opts.model = state.opts.model or ""
    state.opts.model_options = state.opts.model_options or {}
    state.opts.window = state.opts.window or {}
    state.opts.prompt = state.opts.prompt or {}
    state.opts.key_mappings = state.opts.key_mappings or {}

    -- Set toggle chat key mapping on initialization
    if opts.key_mappings.toggle_chat then
        vim.keymap.set(
            opts.key_mappings.toggle_chat.mode,
            opts.key_mappings.toggle_chat.lhs,
            "<cmd>EchoChat<CR>",
            { noremap = true, silent = true }
        )
    end
end

function M.create_chat_window()
    local function get_window_dimensions(user_width)
        local width =
            math.floor(vim.api.nvim_win_get_width(0) * (user_width / 100))
        local height = math.floor(vim.api.nvim_win_get_height(0) * 0.90)

        return width, height
    end

    -- Default of 35 for user chosen width
    local win_width, win_height =
        get_window_dimensions(state.opts.window.width or 35)

    local col

    if state.opts.window.position == "left" then
        -- Float window will be on the left side
        col = 0
    else
        -- Float window will be on the right side (Default)
        col = vim.api.nvim_win_get_width(0) - win_width
    end

    if not vim.api.nvim_buf_is_valid(state.bufnr) then
        state.bufnr = vim.api.nvim_create_buf(false, true)
    end

    -- Default to bottom
    local row = 0

    if state.opts.prompt.prompt_position == "top" then
        row = 4
    end

    state.winid = vim.api.nvim_open_win(state.bufnr, true, {
        relative = "editor", -- Floating window relative to the entire editor
        width = win_width,
        height = win_height,
        row = row,
        col = col,
        border = state.opts.window.border or "rounded",
        style = "minimal",
        title = state.opts.window.title or "ECHO",
        title_pos = "center",
    })

    vim.api.nvim_set_option_value("modifiable", true, { buf = state.bufnr })

    -- Get current lines in buffer
    local lines = vim.api.nvim_buf_get_lines(state.bufnr, 0, -1, false)

    local welcome_text = "What can I help with?"

    local text_len = #welcome_text
    local text_row = math.floor(win_height / 2)
    local text_col = math.floor((win_width - text_len) / 2)

    -- If the buffer is empty or doesn't already contain a line of text, set it
    -- (Assuming one line of text means only the welcome message is present)
    if #lines == 0 or #lines == 1 then
        vim.api.nvim_buf_set_lines(
            state.bufnr,
            text_row,
            text_row,
            false,
            { string.rep(" ", text_col) .. welcome_text }
        )
    end

    vim.api.nvim_set_option_value("modifiable", false, { buf = state.bufnr })

    Prompt.init_prompt_input_opts({
        model = state.opts.model,
        model_options = state.opts.model_options,
        prompt = {
            prompt_position = state.opts.prompt.prompt_position,
            title = state.opts.prompt.title,
            border = state.opts.prompt.border,
            start_insert_mode = state.opts.prompt.start_insert_mode,
        },
        parent_window = {
            winid = state.winid,
            width = win_width,
            col = col,
        },
    })

    local prompt = Prompt.create_prompt_input()

    state.prompt.winid = prompt.winid
    state.prompt.bufnr = prompt.bufnr

    M.setup_keymaps(state.opts.key_mappings)
end

function M.setup_keymaps(key_mappings)
    if key_mappings.submit_prompt then
        vim.keymap.set(
            key_mappings.submit_prompt.mode,
            key_mappings.submit_prompt.lhs,
            "<cmd>EchoSubmitPrompt<CR>",
            { buffer = state.prompt.bufnr, noremap = true, silent = true }
        )
    end
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
