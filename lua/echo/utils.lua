local Job = require("plenary.job")
local Curl = require("plenary.curl")

local M = {}

function M.print(...)
    local args = {}

    for _, arg in ipairs({ ... }) do
        table.insert(args, vim.inspect(arg))
    end

    print(unpack(args))

    return ...
end

function M.trim(str)
    return str:gsub("^%s+", ""):gsub("%s+$", "")
end

function M.set_buf_lines(buf, start, ending, strict_indexing, replacement)
    local isModifiable =
        vim.api.nvim_get_option_value("modifiable", { buf = buf })
    vim.api.nvim_set_option_value("modifiable", true, { buf = buf })
    vim.api.nvim_buf_set_lines(buf, start, ending, strict_indexing, replacement)
    vim.api.nvim_set_option_value("modifiable", isModifiable, { buf = buf })
end

function M.wrap_text(text, width)
    local lines = {}
    local current_line = ""

    -- Split the text by spaces to get individual words
    for word in text:gmatch("%S+") do
        -- Check if adding the next word would exceed the width
        if #current_line + #word + (current_line == "" and 0 or 1) > width then
            -- If so, push the current line and start a new one with the current word
            table.insert(lines, current_line)
            current_line = word
        else
            -- Otherwise, just add the word to the current line
            if current_line == "" then
                current_line = word
            else
                current_line = current_line .. " " .. word
            end
        end
    end

    -- Add the last line if there is any remaining text
    if #current_line > 0 then
        table.insert(lines, current_line)
    end

    return lines
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

-- -- Starts the Ollama server but automatically terminates upon quitting Neovim
-- function M.start_server()
--     Job:new({
--         command = "ollama",
--         args = { "serve" },
--         on_exit = function(_job, exit_code)
--             --[[
--                 In Lua, the only values that are `falsy` are `nil` and `false`.
--                 Every other value (`0`, `{}`, "", etc.) is `truthy`
--
--                 `~=` is the inequality operator (like `!=`)
--             --]]
--             if exit_code ~= 0 then
--                 error("failed to start server")
--             end
--         end,
--     }):start()
-- end

---@param model string
function M.is_model_available(model)
    Curl.get("http://localhost:11434/api/tags", {
        on_error = function(err)
            if err.exit == 7 then
                error(
                    "ollama server not running. start it with the command `ollama serve` in a separate terminal/session"
                )
            else
                M.print(err)
            end
        end,
        callback = function(res)
            vim.schedule(function()
                local success, decoded_body =
                    pcall(vim.fn.json_decode, res.body)

                if not success then
                    error("failed to parse JSON response")
                end

                local model_found = false

                --[[
                    Iterators in Lua:

                    pairs: Iterates over EVERY key in a table. Order is NOT guaranteed

                    ipairs: Iterates over ONLY numeric keys in a table starting at 1.
                            Order IS guaranteed
                --]]
                for _, model_data in pairs(decoded_body.models) do
                    if model == model_data.model then
                        model_found = true
                        break
                    end
                end

                if not model_found then
                    error(
                        "model '"
                            .. model
                            .. "' could not be found. available models: \n"
                            .. table.concat(
                                vim.tbl_map(function(m)
                                    return m.model
                                end, decoded_body.models),
                                "\n"
                            )
                            .. "\n"
                    )
                end
            end)
        end,
    })
end

return M
