local M = {}

--- @class EchoConfig
--- @field model string
--- @field model_options ModelConfig
--- @field include_current_buffer boolean
--- @field system_message string
--- @field chat_window ChatConfig
--- @field prompt_window PromptConfig
--- @field key_mappings KeymapConfig

--- @class ModelConfig
--- @field mirostat number
--- @field mirostat_eta number
--- @field mirostat_tau number
--- @field num_ctx number
--- @field repeat_last_n number
--- @field repeat_penalty number
--- @field temperature number
--- @field seed number
--- @field stop string
--- @field tfs_z number
--- @field num_predict number
--- @field top_k number
--- @field top_p number
--- @field min_p number
--- @field stream boolean

--- @class ChatConfig
--- @field position string
--- @field width number
--- @field title string|nil
--- @field title_position string
--- @field border string
--- @field spinner_color string

--- @class PromptConfig
--- @field position string
--- @field title string|nil
--- @field title_position string
--- @field border string|table
--- @field start_insert_mode boolean
--- @field bg_color string

--- @class KeymapConfig
--- @field toggle_chat Keymap
--- @field toggle_menu Keymap
--- @field submit_prompt Keymap
--- @field clear_chat Keymap

--- @class Keymap
--- @field mode string[]
--- @field lhs string

--- @class EchoPartialConfig
--- @field model string?
--- @field model_options ModelConfig?
--- @field include_current_buffer boolean?
--- @field system_message string?
--- @field chat_window ChatConfig?
--- @field prompt_window PromptConfig?
--- @field key_mappings KeymapConfig?

--- @param config EchoPartialConfig
--- @return EchoConfig
function M.get_config(config)
    -- Merge the default config with the provided config
    return vim.tbl_extend("force", {}, M.get_default_config(), config or {})
end

--- @return EchoConfig
function M.get_default_config()
    return {
        model = "",
        model_options = {
            mirostat = 0,
            mirostat_eta = 0.1,
            mirostat_tau = 5.0,
            num_ctx = 2048,
            repeat_last_n = 64,
            repeat_penalty = 1.1,
            temperature = 0.8,
            seed = 0,
            stop = "",
            tfs_z = 1,
            num_predict = -1,
            top_k = 40,
            top_p = 0.9,
            min_p = 0.0,
            stream = true,
        },
        include_current_buffer = true,
        system_message = "",
        chat_window = {
            position = "right",
            width = 30.0,
            title = nil,
            title_position = "center",
            border = "rounded",
            spinner_color = "#FFFFFF",
        },
        prompt_window = {
            position = "bottom",
            title = nil,
            title_position = "center",
            border = "rounded",
            start_insert_mode = true,
            bg_color = "#404040",
        },
        key_mappings = {
            toggle_chat = {
                mode = { "n" },
                lhs = "<C-c>",
            },
            toggle_menu = {
                mode = { "n" },
                lhs = "<C-m>",
            },
            submit_prompt = {
                mode = { "n", "i" },
                lhs = "<CR>",
            },
            clear_chat = {
                mode = { "n" },
                lhs = "<leader>c",
            },
        },
    }
end

return M
