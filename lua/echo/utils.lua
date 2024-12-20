local M = {}

-- Inspects and prints each argument, then returns the original arguments
function M.print(...)
    local args = {}

    for _, arg in ipairs({ ... }) do
        table.insert(args, vim.inspect(arg))
    end

    print(unpack(args))

    return ...
end

-- Removes leading and trailing whitespace from the given string
function M.trim(str)
    return str:gsub("^%s+", ""):gsub("%s+$", "")
end

--[[
    Temporarily sets buffer's modifiable option to true, sets the specified lines,
    and then restores the buffer's original modifiable option
--]]
function M.set_buf_lines(buf, start, ending, strict_indexing, replacement)
    local isModifiable =
        vim.api.nvim_get_option_value("modifiable", { buf = buf })

    vim.api.nvim_set_option_value("modifiable", true, { buf = buf })

    vim.api.nvim_buf_set_lines(buf, start, ending, strict_indexing, replacement)

    vim.api.nvim_set_option_value("modifiable", isModifiable, { buf = buf })
end

-- Splits the text into lines of words, ensuring each line doesn't exceed the specified width
function M.wrap_text(text, width)
    local lines = {}
    local current_line = ""

    -- Split the text by spaces to get individual words
    for word in text:gmatch("%S+") do
        -- Check if adding the next word would exceed the width
        if #current_line + #word + (current_line == "" and 0 or 1) > width then
            -- Push current line and start a new one with the current word
            table.insert(lines, current_line)
            current_line = word
        else
            -- Add the word to the current line
            if current_line == "" then
                current_line = word
            else
                current_line = current_line .. " " .. word
            end
        end
    end

    -- Add remaining text
    if #current_line > 0 then
        table.insert(lines, current_line)
    end

    return lines
end

function M.is_command_installed(command)
    -- Using pcall for better error handling
    local success, err = pcall(function()
        -- Runs synchronously
        local obj = vim.system({ "command", "-v", command }, { text = true })
            :wait()

        if obj.code ~= 0 then
            error(
                "the command '"
                    .. command
                    .. "' is not installed or not found in the PATH"
            )
        end
    end)

    -- vim.system error
    if err and err:match("no such file or directory") then
        err = "the command 'command' is not installed or not found in the PATH"
    end

    return success, err
end

return M
