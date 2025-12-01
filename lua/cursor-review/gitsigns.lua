-- cursor-review.nvim gitsigns module
-- Setup gitsigns with hunk navigation and staging keymaps

local M = {}

--- Setup gitsigns with cursor-review keybindings
---@param config table Plugin configuration
function M.setup(config)
  local ok, gitsigns = pcall(require, "gitsigns")
  if not ok then
    vim.notify("cursor-review: gitsigns.nvim is required", vim.log.levels.ERROR)
    return
  end

  -- Build gitsigns config with our on_attach
  local gs_config = vim.tbl_deep_extend("force", config.gitsigns, {
    on_attach = function(bufnr)
      local gs = package.loaded.gitsigns
      local km = config.keymaps

      local function map(mode, l, r, opts)
        opts = opts or {}
        opts.buffer = bufnr
        vim.keymap.set(mode, l, r, opts)
      end

      -- Navigation between hunks
      if km.next_hunk then
        map("n", km.next_hunk, function()
          if vim.wo.diff then
            return km.next_hunk
          end
          vim.schedule(function()
            gs.next_hunk()
          end)
          return "<Ignore>"
        end, { expr = true, desc = "Next hunk" })
      end

      if km.prev_hunk then
        map("n", km.prev_hunk, function()
          if vim.wo.diff then
            return km.prev_hunk
          end
          vim.schedule(function()
            gs.prev_hunk()
          end)
          return "<Ignore>"
        end, { expr = true, desc = "Previous hunk" })
      end

      -- ACCEPT changes (stage hunk)
      if km.stage_hunk then
        map("n", km.stage_hunk, gs.stage_hunk, { desc = "Stage (accept) hunk" })
        map("v", km.stage_hunk, function()
          gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end, { desc = "Stage selection" })
      end

      -- REJECT changes (reset hunk)
      if km.reset_hunk then
        map("n", km.reset_hunk, gs.reset_hunk, { desc = "Reset (reject) hunk" })
        map("v", km.reset_hunk, function()
          gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end, { desc = "Reset selection" })
      end

      -- Preview hunk
      if km.preview_hunk then
        map("n", km.preview_hunk, gs.preview_hunk, { desc = "Preview hunk" })
      end

      -- Undo stage
      if km.undo_stage then
        map("n", km.undo_stage, gs.undo_stage_hunk, { desc = "Undo stage hunk" })
      end

      -- Stage/reset buffer
      if km.stage_buffer then
        map("n", km.stage_buffer, gs.stage_buffer, { desc = "Stage buffer" })
      end

      if km.reset_buffer then
        map("n", km.reset_buffer, gs.reset_buffer, { desc = "Reset buffer" })
      end

      -- Blame
      if km.blame_line then
        map("n", km.blame_line, function()
          gs.blame_line({ full = true })
        end, { desc = "Blame line" })
      end

      if km.toggle_blame then
        map("n", km.toggle_blame, gs.toggle_current_line_blame, { desc = "Toggle line blame" })
      end

      -- Diff
      if km.diff_this then
        map("n", km.diff_this, gs.diffthis, { desc = "Diff against index" })
      end

      if km.diff_last then
        map("n", km.diff_last, function()
          gs.diffthis("~")
        end, { desc = "Diff against last commit" })
      end
    end,
  })

  gitsigns.setup(gs_config)
end

return M

