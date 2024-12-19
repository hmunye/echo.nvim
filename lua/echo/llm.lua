local Curl = require("plenary.curl")

local M = {}

function M.generate_completion(opts, prompt, callback)
    -- Currently not streaming response
    Curl.post("http://localhost:11434/api/generate", {
        body = vim.fn.json_encode({
            model = opts.model,
            prompt = prompt,
            options = {
                temperature = opts.model_options.temperature or 0.8,
                seed = opts.model_options.seed or 0,
                num_ctx = opts.model_options.num_ctx or 2048,
                num_predict = opts.model_options.num_predict or -1,
            },
            system = opts.model_options.system_prompt or "",
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
                callback(vim.fn.json_decode(res.body))
            end)
        end,
    })
end

return M
