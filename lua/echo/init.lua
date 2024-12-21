--[[
    Files in the `lua` directory are not immediately executed on startup of
    Neovim but are available to the user to `require`
--]]

local Utils = require("echo.utils")
local Config = require("echo.config")

---@class Echo
---@field config EchoConfig
local Echo = {}

-- Set the index of Echo to itself
Echo.__index = Echo

---@return Echo
function Echo:new()
    local config = Config.get_default_config()

    local echo = setmetatable({
        config = config,
    }, self)

    return echo
end

function Echo.setup(opts)
    local success, err = Utils.is_command_installed("ollama")
    if not success then
        vim.api.nvim_echo({
            { err, "ErrorMsg" },
        }, true, {})

        return
    end

    success, err = Utils.is_command_installed("curl")
    if not success then
        vim.api.nvim_echo({
            { err, "ErrorMsg" },
        }, true, {})

        return
    end

    if not opts.model then
        vim.api.nvim_echo({
            {
                "'model' field must be specified in the configuration",
                "ErrorMsg",
            },
        }, true, {})

        return
    end

    -- Placing require here ensures the `chat` module is not loaded into memory
    -- before initial checks
    require("echo.chat").init_chat_window_opts(opts)
end

return Echo
