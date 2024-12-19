local Utils = require("echo.utils")
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
    spinner = {
        index = 1,
        timer = nil,
        bufnr = -1,
        winid = -1,
        frames = {
            "⠋",
            "⠙",
            "⠹",
            "⠸",
            "⠼",
            "⠴",
            "⠦",
            "⠧",
            "⠇",
            "⠏",
        },
    },
}

local function set_buf_lines(buf, start, ending, strict_indexing, replacement)
    local isModifiable =
        vim.api.nvim_get_option_value("modifiable", { buf = buf })
    vim.api.nvim_set_option_value("modifiable", true, { buf = buf })
    vim.api.nvim_buf_set_lines(buf, start, ending, strict_indexing, replacement)
    vim.api.nvim_set_option_value("modifiable", isModifiable, { buf = buf })
end

local function start_spinner()
    local win_width = vim.api.nvim_win_get_width(state.winid)
    local win_height = vim.api.nvim_win_get_height(state.winid)

    local text_row = math.floor(win_height / 2)
    local text_col = math.floor((win_width - 1) / 2)

    local options = {
        relative = "win",
        win = state.winid,
        width = 1,
        height = 1,
        col = text_col,
        row = text_row,
        style = "minimal",
    }

    -- Create buffer and window for the spinner
    state.spinner.bufnr = vim.api.nvim_create_buf(false, true)
    state.spinner.winid =
        vim.api.nvim_open_win(state.spinner.bufnr, false, options)

    -- Start a timer to cycle through the spinner frames
    state.spinner.timer = vim.loop.new_timer()
    state.spinner.timer:start(
        0,
        100,
        vim.schedule_wrap(function()
            if vim.api.nvim_buf_is_valid(state.spinner.bufnr) then
                set_buf_lines(
                    state.spinner.bufnr,
                    0,
                    -1,
                    false,
                    { state.spinner.frames[state.spinner.index] }
                )
            end
            state.spinner.index = (state.spinner.index % #state.spinner.frames)
                + 1
        end)
    )
end

local function stop_spinner()
    if state.spinner.timer then
        state.spinner.timer:stop()
        state.spinner.timer:close()
        state.spinner.timer = nil

        if state.spinner.winid then
            vim.api.nvim_win_close(state.spinner.winid, true)
        end
        if state.spinner.bufnr then
            vim.api.nvim_buf_delete(state.spinner.bufnr, { force = true })
        end
    end
end

local function append_user_prompt(input)
    start_spinner()

    vim.defer_fn(function()
        stop_spinner()

        local response = "This is a response to your prompt: " .. input
        local win_width = vim.api.nvim_win_get_width(state.winid)
        local win_height = vim.api.nvim_win_get_height(state.winid)

        local text_col = math.floor((win_width - #response) / 2)

        local lines = vim.api.nvim_buf_get_lines(state.bufnr, 0, -1, false)
        local trimmed_line = Utils.trim(lines[2])

        if #lines == 2 and trimmed_line == "What can I help with?" then
            -- Overwrite the welcome message with the response
            set_buf_lines(
                state.bufnr,
                1, -- Replace the line
                2,
                false,
                { string.rep(" ", text_col) .. response }
            )
        else
            local text_row = math.floor(win_height / 2)

            -- Append the response
            set_buf_lines(
                state.bufnr,
                text_row + 1, -- Place the response on the next line
                text_row + 2, -- Avoid overwriting
                false,
                { string.rep(" ", text_col) .. response }
            )
        end
    end, 2000) -- Wait for 2 seconds to simulate a delay
end

local function setup_keymaps(key_mappings)
    if key_mappings.submit_prompt then
        vim.keymap.set(
            key_mappings.submit_prompt.mode,
            key_mappings.submit_prompt.lhs,
            "<cmd>EchoSubmitPrompt<CR>",
            { buffer = state.prompt.bufnr, noremap = true, silent = true }
        )
    end
end

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
        local height = math.floor(vim.api.nvim_win_get_height(0) * 0.85)

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
        title_pos = state.opts.window.title_position or "center",
    })

    vim.api.nvim_set_option_value("modifiable", true, { buf = state.bufnr })

    -- Get current lines in buffer
    local lines = vim.api.nvim_buf_get_lines(state.bufnr, 0, -1, false)

    -- BUG: Unexpected behavior when opening Oil file explorer within
    -- prompt input buffer and toggling chat window
    local welcome_text = "What can I help with?"

    local text_len = #welcome_text
    local text_row = math.floor(win_height / 2)
    local text_col = math.floor((win_width - text_len) / 2)

    -- If the buffer is empty or doesn't already contain a line of text, set it
    -- (Assuming one line of text means only the welcome message is present)
    if #lines < 2 then
        set_buf_lines(
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
            title_position = state.opts.prompt.title_position,
            border = state.opts.prompt.border,
            start_insert_mode = state.opts.prompt.start_insert_mode,
        },
        parent_window = {
            winid = state.winid,
            width = win_width,
            col = col,
        },
        submit_callback = function(input)
            append_user_prompt(input)
        end,
    })

    local prompt = Prompt.create_prompt_input()

    state.prompt.winid = prompt.winid
    state.prompt.bufnr = prompt.bufnr

    setup_keymaps(state.opts.key_mappings)
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
