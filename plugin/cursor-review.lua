-- cursor-review.nvim plugin loader
-- This file is automatically sourced by Neovim

-- Prevent double-loading
if vim.g.loaded_cursor_review then
  return
end
vim.g.loaded_cursor_review = true

-- Check Neovim version
if vim.fn.has("nvim-0.8") == 0 then
  vim.api.nvim_err_writeln("cursor-review.nvim requires Neovim 0.8 or higher")
  return
end

-- Plugin is lazy-loaded, setup() must be called by the user
-- This allows for configuration before initialization

