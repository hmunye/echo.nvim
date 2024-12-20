<div align="center">
  
<img src="https://github.com/user-attachments/assets/224eac11-449e-4779-abf4-d3473892739e" width="400px" alt="ECHO logo"/>

#### AI in your terminal, powered locally

[![Neovim](https://img.shields.io/static/v1?&style=for-the-badge&label=Neovim&message=v0.10%2b&logo=neovim)](https://neovim.io)
[![Lua](https://img.shields.io/badge/Lua-blue.svg?style=for-the-badge&logo=lua)](http://www.lua.org)
</div>

## TOC
* [Overview](#overview)
* [Installation](#installation)
* [Usage](#usage)

## Overview
**echo.nvim** is a Neovim plugin that integrates local, AI-powered chat and real-time assistance directly into your terminal via Ollama, offering a private and seamless experience within your development environment.

## Installation

### Prerequisites:
- **Neovim 0.10.0+**
- [**Ollama**](https://ollama.com/download)
- **curl**

### Pull a Model: 
You need to download a model to use with Ollama. For example, to pull the `llama3.2:3b` model, run the following command:

```bash
ollama pull llama3.2:3b
```
### Start the Ollama Server: 
You must run the Ollama server to interact with the model. Start the server with the following command:

```bash
ollama serve
```
### Setup Plugin:

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
return {
    "hmunye/echo.nvim",
    dependencies = {
        "nvim-lua/plenary.nvim",
        {
            "MeanderingProgrammer/render-markdown.nvim",
            opts = {
                enabled = true,
                file_types = { "echo" },
                render_modes = true,
                anti_conceal = { enabled = false },
            },
            ft = { "echo" },
        },
    },
    config = function() 
	require("echo").setup({
            model = "llama3.2:3b", --- REQUIRED

            --- REST ARE OPTIONAL
            model_options = {
                temperature = 0.8, -- Controls the randomness of the model's output. Higher values (1.0) make the output more random and creative, while lower values (e.g., 0.2) make it more focused and deterministic (Default: 0.8)
                seed = 0, -- Random seed for repeatable output. If set to a specific value, the model will produce the same output each time given the same input. (Default: 0)
                num_ctx = 2048, -- The size of the context window used by the model to generate the next token. A larger window allows the model to consider more previous text. (Default: 2048)
                num_predict = -1, -- Maximum number of tokens the model is allowed to generate in response to a prompt. A value of -1 means there is no limit to the number of tokens generated. (Default: -1 for unlimited generation)
                system_prompt = "", -- A system-level prompt that sets the context or behavior of the model, often used to define rules or constraints for the conversation. (Default: "")
            },

            -- Chat window configuration
            window = {
                position = "right", -- The position of the window relative to current window. Options: "right" or "left". (Default: "right")
                width = 30, -- The width of the window as a percentage of the total available window width. (Default: 35)
                title = "ECHO", -- The title of the window. (Default: "ECHO")
                title_position = "center", -- The position of the window's title. Options: "center", "left", or "right". (Default: "center")
                border = "rounded", -- The style of the window's border. (Default: "rounded")
                spinner_color = "#FFFFFF", -- The color for the spinner highlight. (Default: "#FFFFFF")
            },

            -- Prompt window configuration
            prompt = {
                prompt_position = "bottom", -- The position of the prompt relative to the chat window. Options: "top" or "bottom". (Default: "bottom")
                title = nil, -- The title of the prompt window. (Default: model's name)
                title_position = "left", -- The position of the prompt window's title. Options: "center", "left", or "right". (Default: "left")
                border = "rounded", -- The style of the prompt's border. (Default: "rounded")
                start_insert_mode = true, -- If true, the prompt starts in insert mode. (Default: true)
                bg_color = "#404040", -- The background color for the prompt highlight. (Default: "#404040")
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
    end,
}
```
## Usage

### `EchoChat` Command:

Used to toggle the visibility of the chat window, spinner, and prompt window

You can customize the key mapping by modifying the key_mappings section. For example, to map the toggle command to the F1 key:

```lua
key_mappings = {
    toggle_chat = {
        mode = { "n" },    -- Normal mode
        lhs = "<F1>",
    },
}
```

### `EchoSubmitPrompt` Command:

Submits the user's input from the prompt. If the input is non-empty, it will send the request to the local server and clear the input field

You can customize the key mapping by modifying the key mappings section. For example, to map the submit action to Ctrl + Enter:

```lua
key_mappings = {
    submit_prompt = {
        mode = { "n", "i" },  -- Normal and Insert mode
        lhs = "<C-CR>",
    },
}
```

### `EchoClear` Command:

Clears the chat window buffer. Will not clear the chat history

You can customize the key mapping by modifying the key mappings section. For example, to map the clear chat action to \<leader\> c:

```lua
key_mappings = {
    clear_window = {
        mode = { "n" },    -- Normal mode
        lhs = "<leader>c",
    },
}
