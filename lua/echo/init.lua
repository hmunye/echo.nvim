--[[
    Files in the `lua` directory are not immediately executed on startup of
    Neovim but are available to the user to `require`
--]]

local Utils = require("echo.utils")
local Chat = require("echo.chat")

-- Tables `{}` are the only built-in data structure
local Echo = {}

-- `_` refers to private module member. Not enforced
-- Echo._example = {}

--[[
    Every function returns nil by default if no explicit return value
    is provided. `setup` is a key of the `Echo` table
--]]
Echo.setup = function(opts)
    Utils.is_command_installed("ollama")
    Utils.is_command_installed("curl")
    Utils.is_model_available(opts.model)

    Chat.init_chat_window_opts(opts)

    vim.keymap.set("n", "<leader>c", "<cmd>EchoChat<CR>")
end

-- TODO: Implement options
Echo.setup({
    model = "llama3.1:latest",
    model_options = {
        temperature = 0.8, -- model temperature for creativity/randomness (Default: 0.8)
        seed = 0, -- random seed for repeatable output (Default: 0)
        num_ctx = 2048, -- sets the size of the context window used to generate the next token (Default: 2048)
        num_predict = -1, -- maximum number of tokens to generate (Default: -1 for unlimited generation)
        system_prompt = "", -- system message to set the context or behavior of the model (e.g., defining role or guidelines)
    },
    window = {
        position = "right", -- the position of the window (right or left)
        width = 30, -- % of current window width
        title = "", -- title of window
        border = "rounded", -- border style for the window (rounded, single, double, etc.)
    },
    prompt = {
        prompt_position = "bottom", -- position of the prompt relative to chat window (top or bottom)
    },
    start_insert_mode = true, -- start with prompt in insert mode
    key_mappings = {
        toggle = "<Esc>", -- toggle the chat window
        submit_prompt = "<Enter>", -- send prompt request
    },
})

return Echo
