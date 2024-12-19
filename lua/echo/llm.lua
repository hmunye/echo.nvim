local Curl = require("plenary.curl")

local M = {}

local state = {
    messages = {},
    has_system_message = false,
}

-- TODO: handle streaming response instead
function M.generate_chat(opts, prompt, callback)
    if not state.has_system_message then
        local system_message = {}

        if opts.model_options.system_prompt then
            system_message = {
                role = "system",
                content = opts.model_options.system_prompt,
            }

            -- Update chat memory once with system prompt if provided
            table.insert(state.messages, system_message)
        end

        state.has_system_message = true
    end

    local user_message = {
        role = "user",
        content = prompt,
    }

    -- Update chat memory with user prompt
    table.insert(state.messages, user_message)

    Curl.post("http://localhost:11434/api/chat", {
        body = vim.fn.json_encode({
            model = opts.model,
            messages = state.messages,
            options = {
                temperature = opts.model_options.temperature or 0.8,
                seed = opts.model_options.seed or 0,
                num_ctx = opts.model_options.num_ctx or 2048,
                num_predict = opts.model_options.num_predict or -1,
            },
            stream = false,
        }),
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
                local res_body = vim.fn.json_decode(res.body)

                -- Update chat memory with full message (role and content)
                table.insert(state.messages, res_body.message)

                callback(res_body.message.content)
            end)
        end,
    })
end

return M
