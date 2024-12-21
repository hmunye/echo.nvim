<div align="center">
  
<img src="https://github.com/user-attachments/assets/224eac11-449e-4779-abf4-d3473892739e" width="400px" alt="ECHO logo"/>

#### AI in your terminal, powered locally

[![Neovim](https://img.shields.io/static/v1?&style=for-the-badge&label=Neovim&message=v0.10%2b&logo=neovim)](https://neovim.io)
[![Lua](https://img.shields.io/badge/Lua-blue.svg?style=for-the-badge&logo=lua)](http://www.lua.org)
</div>

## TOC
* [Overview](#overview)
* [Features](#features)
* [Installation](#installation)
* [Usage](#usage)

## Overview
**echo.nvim** is a Neovim plugin that provides local, AI-driven chat and real-time assistance in your terminal via Ollama. A private, seamless experience within your development workflow.

## Features
- [ ] Option to enable/disable streaming of generated responses to chat buffer
- [ ] Ability to dynamically switch between locally available models
- [ ] Control over whether the current buffer is included as context for the model
- [x] Configuration of model parameters (e.g., temperature, system prompt)
- [x] Support for including chat history (previous prompts and responses) as context in each request 

## Installation

### Prerequisites:
- **Neovim 0.10+**
- [**Ollama**](https://ollama.com/download)
- **curl**

### Start Ollama Server: 
You must run the Ollama server to interact with models. Start the server with the following command:

```bash
ollama serve
```
### Pull Model: 
You need to download a model to use with Ollama. For example, to pull the `llama3.2:3b` model, run the following command:

```bash
ollama pull llama3.2:3b
```
### Plugin Setup:

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
return {
    "hmunye/echo.nvim",
    event = "VeryLazy",
    lazy = false,
    -- NO DEPENDENCIES!
    dependencies = {},
    config = function() 
        require("echo").setup({
            -- (string) The model to be used for initialization.
            -- REQUIRED
            model = "llama3.2:3b",

            -- All configuration below is optional and have default values if not specified.
            model_options = {
                -- (int) Enables Mirostat sampling to control perplexity
                -- dynamically during text generation. Mirostat adjusts the
                -- value of k in top-k decoding to maintain a balanced perplexity
                -- range, preventing both the "boredom trap" (repetitive text)
                -- and the "perplexity trap" (loss of coherence).
                -- Options:
                -- 0 = Disabled,
                -- 1 = Mirostat,
                -- 2 = Mirostat 2.0
                -- Default is 0
                mirostat = 0,

                -- (float) Mirostat learning rate (eta) controls how quickly
                -- the algorithm adapts based on the generated text's perplexity.
                -- Lower values result in slower adjustments, while higher
                -- values make the model more responsive to changes.
                -- Default is 0.1
                mirostat_eta = 0.1,

                -- (float) Mirostat target entropy (tau) influences the balance
                -- between output coherence and diversity. A lower tau favors
                -- more coherent output (less randomness), while a higher tau
                -- promotes more diverse text.
                -- Default is 5.0
                mirostat_tau = 5.0,

                -- (int) Defines the context window size, or how much of the past
                -- text the model uses to generate new tokens. The larger the number,
                -- the more context the model has to work with, but it requires
                -- more memory.
                -- Default is 2048 tokens
                num_ctx = 2048,

                -- (int) Sets the number of recent tokens the model checks to
                -- avoid repeating content.
                -- 0 means no repetition check, -1 uses the num_ctx value.
                -- Default is 64 tokens
                repeat_last_n = 64,

                -- (float) Controls the penalty for repeating words or phrases.
                -- Higher values penalize repetition more strongly.
                -- Default is 1.1
                repeat_penalty = 1.1,

                -- (float) Temperature affects response creativity.
                -- Higher values (e.g., 1.0) result in more diverse outputs, while
                -- lower values (e.g., 0.5) lead to more predictable text.
                -- Default is 0.8
                temperature = 0.8,

                -- (int) Sets the random number seed. If you want deterministic output,
                -- use the same seed with the same input and model settings.
                -- Default is 0
                seed = 0,

                -- (string) Specifies the stop sequences, which will stop text
                -- generation when matched. This helps control when the model
                -- should stop generating, such as ending after a certain phrase.
                -- Default is ""
                stop = "",

                -- (float) Tail Free Sampling. Affects the impact of less likely
                -- tokens on the output. Higher values (e.g., 2.0) reduce the
                -- influence of unlikely tokens, ensuring more focused text.
                -- Default is 1
                tfs_z = 1,

                -- (int) Limits the number of tokens the model can generate
                -- in one pass. Set to -1 for unlimited generation.
                -- Default is -1
                num_predict = -1,

                -- (int) Top-k sampling: Limits the possible next tokens to the
                -- top-k most likely choices. A higher value (e.g., 100) increases
                -- output diversity, while a lower value (e.g., 10) makes it
                -- more conservative.
                -- Default is 40
                top_k = 40,

                -- (float) Top-p sampling (nucleus sampling) works together
                -- with top-k to control diversity. A higher value (e.g., 0.95)
                -- leads to more diverse outputs, while a lower value (e.g., 0.5)
                -- makes the model more conservative.
                -- Default is 0.9
                top_p = 0.9,

                -- (float) Minimum probability for a token to be considered,
                -- ensuring more consistent and diverse outputs. Higher values
                -- reduce the number of less probable tokens that can be selected.
                -- Default is 0.0
                min_p = 0.0,

                -- (bool) Whether to return the generated response as a single 
                -- response object (false), or a stream of objects (true)
                -- Default is true
                stream = true
            },

            -- (bool) Controls whether the current buffer is included as context for the model.
            -- When enabled, the model will consider the content of the current buffer
            -- along with other provided input when generating response.
            -- Default is true
            include_current_buffer = true,

            -- (string) A system role message that sets the context or behavior
            -- of the model.
            -- -- Default is ""
            system_message = "",

            chat_window = {
                -- (string) The position of the window relative to current window.
                -- Options:
                -- "right",
                -- "left",
                -- Default is "right"
                position = "right",
                -- (float) The width of the window as a percentage of the total available window width.
                -- Default is 35.0
                width = 30.0,
                -- (string) The title of the window.
                -- Setting to `nil` defaults it to "ECHO"
                title = nil,
                -- (string) The position of the window's title.
                -- Options:
                -- "center",
                -- "right",
                -- "left",
                -- Default is "center"
                title_position = "center",
                -- (string | table) The style of the window's border.
                -- Options:
                -- "none"
                -- "single"
                -- "double"
                -- "rounded"
                -- "shadow"
                -- Custom (ex. {'╭', '─', '╮', '│', '╯', '─', '╰', '│'} )
                -- Default: "rounded"
                border = "rounded",
                -- (string) The color for the spinner highlight.
                -- Default is "#FFFFFF"
                spinner_color = "#FFFFFF",
            },

            prompt_window = {
                -- (string) The position of the prompt relative to the chat window.
                -- Options:
                -- "top",
                -- "bottom",
                -- Default is "bottom"
                position = "bottom",
                -- (string) The title of the window.
                -- Setting to `nil` defaults it to current model's name
                title = nil,
                -- (string) The position of the window's title.
                -- Options:
                -- "center",
                -- "right",
                -- "left",
                -- Default is "left"
                title_position = "center",
                -- (string | table) The style of the window's border.
                -- Options:
                -- "none"
                -- "single"
                -- "double"
                -- "rounded"
                -- "shadow"
                -- Custom (ex. {'╭', '─', '╮', '│', '╯', '─', '╰', '│'} )
                -- Default: "rounded"
                border = "rounded",
                -- (bool) If true, the prompt will start in insert mode.
                -- Default is true
                start_insert_mode = true,
                -- (string) The background color for the prompt highlight. (
                -- Default is "#404040"
                bg_color = "#404040",
            },

            key_mappings = {
                toggle_chat = {
                    -- (table) The mode(s) in which this key mapping is active.
                    -- Commonly used modes:
                    -- "n"     - Normal mode
                    -- "i"     - Insert mode
                    -- "v"     - Visual mode
                    -- "c"     - Command-line mode
                    -- "t"     - Terminal mode
                    -- Can specify multiple modes, e.g., { "n", "i" }.
                    mode = { "n" },

                    -- (string) The left-hand side of the key mapping, 
                    -- the key combination you press to trigger the action.
                    -- Example: "<C-c>" for Ctrl + c.
                    lhs = "<C-c>",
                },
                toggle_menu = {
                    mode = { "" },
                    lhs = "",
                },
                submit_prompt = {
                    mode = { "n", "i" },
                    lhs = "<CR>",
                },
                clear_chat = {
                    mode = { "" },
                    lhs = "",
                },
            },
        })
    end,
}
```
## Usage
