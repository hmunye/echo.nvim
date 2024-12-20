--[[
    Files in the `lua` directory are not immediately executed on startup of
    Neovim but are available to the user to `require`
--]]

local Utils = require("echo.utils")

-- Tables `{}` are the only built-in data structure
local Echo = {}

-- `_` refers to private module member. Not enforced
-- Echo._example = {}

--[[
    Every function returns nil by default if no explicit return value
    is provided
    `setup` is a key of the `Echo` table
--]]
Echo.setup = function(opts)
    local success, err = Utils.is_command_installed("ollama")
    if not success then
        print(err)
        return
    end

    success, err = Utils.is_command_installed("curl")
    if not success then
        print(err)
        return
    end

    require("echo.llama").is_model_available(opts.model)
    require("echo.chat").init_chat_window_opts(opts)

    print("chat initialized")
end

return Echo
