--[[
    Files in the `plugin` directory are immediately executed on startup of Neovim

    `require` loads and executes a module once, caching its return value in the
     global `package.loaded` table to prevent re-execution on subsequent calls.
    Individual plugins share the same `package.loaded` table, so the state
    is consistent across them
--]]

-- require("echo")
