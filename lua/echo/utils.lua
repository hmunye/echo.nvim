local M = {}

local Job = require("plenary.job")

function M.print(...)
    local args = {}

    for _, arg in ipairs({ ... }) do
        table.insert(args, vim.inspect(arg))
    end

    print(unpack(args))

    return ...
end

---@param command string
function M.is_command_installed(command)
    Job:new({
        command = "command",
        args = { "-v", command },
        on_exit = function(_job, exit_code)
            --[[
                In Lua, the only values that are `falsy` are `nil` and `false`.
                Every other value (`0`, `{}`, "", etc.) is `truthy`

                `~=` is the inequality operator (like `!=`)
            --]]
            if exit_code ~= 0 then
                error(command .. " is not installed or not found in the PATH")
            end
        end,
    }):start()
end

return M
