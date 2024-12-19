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

    -- Options related to the model's behavior
    model_options = {
        temperature = 0.8, -- Controls the randomness of the model's output. Higher values (e.g., 1.0) make the output more random and creative, while lower values (e.g., 0.2) make it more focused and deterministic. (Default: 0.8)
        seed = 0, -- Random seed for repeatable output. If set to a specific value, the model will produce the same output each time given the same input. (Default: 0)
        num_ctx = 2048, -- The size of the context window used by the model to generate the next token. A larger window allows the model to consider more previous text but can be more computationally expensive. (Default: 2048)
        num_predict = -1, -- Maximum number of tokens the model is allowed to generate in response to a prompt. A value of -1 means there is no limit to the number of tokens generated. (Default: -1 for unlimited generation)
        system_prompt = "", -- A system-level prompt that sets the context or behavior of the model, often used to define rules or constraints for the conversation. (Default: "")
    },

    -- Chat window configuration
    window = {
        position = "right", -- The position of the window relative to current window. Options: "right" or "left". (Default: "right")
        width = 35, -- The width of the window as a percentage of the total available window width. (Default: 35)
        title = nil, -- The title of the window. (Default: "ECHO")
        title_position = "center", -- The position of the window's title. Options: "center", "left", or "right". (Default: "center")
        border = "single", -- The style of the window's border. (Default: "rounded")
    },

    -- Prompt configuration
    prompt = {
        prompt_position = "bottom", -- The position of the prompt relative to the chat window. Options: "top" or "bottom". (Default: "bottom")
        title = nil, -- The title of the prompt window. (Default: model's name)
        title_position = "left", -- The position of the prompt window's title. Options: "center", "left", or "right". (Default: "left")
        border = "rounded", -- The style of the prompt's border. (Default: "rounded")
        start_insert_mode = true, -- If true, the prompt starts in insert mode. (Default: true)
        bg_color = "#404040", -- The background color for the prompt highlight. (Default: "#404040")
        fg_color = "NONE", -- The text color for the prompt highlight. (Default: "NONE")
    },

    -- Key mappings configuration
    key_mappings = {
        toggle_chat = {
            mode = { "n" }, -- The mode(s) in which this key mapping works.
            lhs = "<C-c>", -- The left-hand side of the key mapping (what you press to trigger the action).
        },
        submit_prompt = {
            mode = { "n", "i" },
            lhs = "<CR>",
        },
    },
})

return Echo
