--[[
    Files in the `lua` directory are not immediately executed on startup of
    Neovim but are available to the user to `require`
--]]

-- Tables `{}` are the only built-in data structure
local M = {}

-- `_` refers to private module member. Not enforced
-- M._example = {}

--[[
    Every function returns nil by default if no explicit return value
    is provided. `setup` is a key of the `M` table
--]]
M.setup = function(opts)
	print(vim.inspect(opts.model))
end

M.setup({
	model = "llama3.1",
})

return M
