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
end

Echo.setup({
    model = "llama3.1:latest", -- REQUIRED
    model_options = {
        temperature = 0.8, -- model temperature for creativity/randomness (Default: 0.8)
        seed = 0, -- random seed for repeatable output (Default: 0)
        num_ctx = 2048, -- sets the size of the context window used to generate the next token (Default: 2048)
        num_predict = -1, -- maximum number of tokens the model is allowed to generate (Default: -1 for unlimited generation)
        system_prompt = "", -- system message to set the context or behavior of the model (Default: "")
    },
    window = {
        position = "right", -- the position of the window, "right" or "left" (Default: "right")
        width = 35, -- % of current window width (Default: 35)
        title = nil, -- title of window (Default: "ECHO")
        title_position = "center", -- position of title. "center", "left", or "right" (Default: "center")
        border = "rounded", -- border style for the window (Default: "rounded")
    },
    prompt = {
        prompt_position = "bottom", -- position of the prompt relative to chat window, "top" or "bottom" (Default: "bottom")
        title = nil, -- title of prompt window (Default: model's name)
        title_position = "left", -- position of title. "center", "left", or "right" (Default: "left")
        border = "rounded", -- border style for the window (Default: "rounded")
        start_insert_mode = true, -- start with prompt in insert mode (Default: true)
    },
    key_mappings = {
        toggle_chat = {
            mode = { "n" },
            lhs = "<C-c>",
        },
        submit_prompt = {
            mode = { "n", "i" },
            lhs = "<CR>",
        },
    },
})

return Echo
