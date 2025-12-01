-- cursor-review.nvim commands module
-- User commands and global keymaps for the review workflow

local M = {}

local ui = require("cursor-review.ui")

--- Setup user commands
---@param config table Plugin configuration
function M.setup(config)
  local cmds = config.commands

  -- CursorCheckpoint: Create a checkpoint commit before running Cursor Agent
  if cmds.checkpoint then
    vim.api.nvim_create_user_command(cmds.checkpoint, function(opts)
      local msg = opts.args ~= "" and opts.args or "checkpoint before cursor agent"

      if not ui.is_git_repo() then
        vim.notify("Not a git repository", vim.log.levels.ERROR)
        return
      end

      local status = ui.get_git_status()
      if status == "" then
        if config.notifications.enable then
          vim.notify("Working tree clean, no checkpoint needed", vim.log.levels.INFO)
        end
        return
      end

      -- Stage all and commit
      vim.fn.system("git add -A")
      local result = vim.fn.system(string.format('git commit -m "%s"', msg))

      if vim.v.shell_error == 0 then
        if config.notifications.enable then
          vim.notify("Checkpoint created: " .. msg, vim.log.levels.INFO)
        end
        pcall(vim.cmd, "Gitsigns refresh")
      else
        vim.notify("Checkpoint failed: " .. result, vim.log.levels.ERROR)
      end
    end, {
      nargs = "?",
      desc = "Create checkpoint commit before running Cursor Agent",
    })
  end

  -- CursorReview: Open diffview to review changes
  if cmds.review then
    vim.api.nvim_create_user_command(cmds.review, function()
      if not ui.is_git_repo() then
        vim.notify("Not a git repository", vim.log.levels.ERROR)
        return
      end

      local status = ui.get_git_status()
      if status == "" then
        if config.notifications.enable then
          vim.notify("No changes to review", vim.log.levels.INFO)
        end
        return
      end

      vim.cmd("DiffviewOpen")

      if config.notifications.enable and config.notifications.verbose then
        vim.notify(
          [[
Review Cursor changes:
  ]c / [c     - Navigate hunks
  <leader>hs  - Accept (stage) hunk
  <leader>hr  - Reject (reset) hunk
  s / -       - Stage/unstage file
  X           - Restore (reject) file
  q           - Close diffview
  :CursorFinalize - Commit accepted changes
]],
          vim.log.levels.INFO
        )
      end
    end, {
      desc = "Open diffview to review Cursor Agent changes",
    })
  end

  -- CursorFinalize: Open floating commit dialog
  if cmds.finalize then
    vim.api.nvim_create_user_command(cmds.finalize, function()
      ui.show_commit_dialog(config, { amend = false })
    end, {
      desc = "Commit staged (accepted) changes with floating dialog",
    })
  end

  -- CursorAmend: Amend staged changes to previous commit
  if cmds.amend then
    vim.api.nvim_create_user_command(cmds.amend, function(opts)
      local staged_count = ui.get_staged_count()

      if staged_count == 0 then
        vim.notify(
          "No staged changes to amend. Use " .. config.keymaps.stage_hunk .. " to stage hunks.",
          vim.log.levels.WARN
        )
        return
      end

      local last_commit = ui.get_last_commit_message()
      if not last_commit then
        vim.notify("No previous commit to amend", vim.log.levels.ERROR)
        return
      end

      if not opts.bang then
        -- Quick amend: keep the same commit message
        local result = vim.fn.system("git commit --amend --no-edit")
        if vim.v.shell_error == 0 then
          if config.notifications.enable then
            vim.notify("Amended commit: " .. last_commit, vim.log.levels.INFO)
          end
          pcall(vim.cmd, "Gitsigns refresh")
        else
          vim.notify("Amend failed: " .. result, vim.log.levels.ERROR)
        end
      else
        -- Show floating input with previous message as default
        ui.show_commit_dialog(config, {
          amend = true,
          default_message = last_commit,
        })
      end
    end, {
      bang = true,
      desc = "Amend staged changes to previous commit (use ! to edit message)",
    })
  end

  -- CursorAbort: Reset all unstaged changes
  if cmds.abort then
    vim.api.nvim_create_user_command(cmds.abort, function()
      ui.confirm("This will discard ALL unstaged changes. Continue?", function()
        vim.fn.system("git checkout -- .")
        pcall(vim.cmd, "Gitsigns refresh")
        vim.cmd("e!") -- Reload current buffer
        if config.notifications.enable then
          vim.notify("All unstaged changes discarded", vim.log.levels.INFO)
        end
      end, function()
        if config.notifications.enable then
          vim.notify("Abort cancelled", vim.log.levels.INFO)
        end
      end)
    end, {
      desc = "Discard all unstaged (rejected) changes",
    })
  end
end

--- Setup global keymaps for workflow commands
---@param config table Plugin configuration
function M.setup_keymaps(config)
  local km = config.keymaps
  local cmds = config.commands

  -- Workflow command keymaps
  if km.checkpoint and cmds.checkpoint then
    vim.keymap.set("n", km.checkpoint, ":" .. cmds.checkpoint .. "<CR>", {
      desc = "Create checkpoint before Cursor",
      silent = true,
    })
  end

  if km.review and cmds.review then
    vim.keymap.set("n", km.review, ":" .. cmds.review .. "<CR>", {
      desc = "Review Cursor changes",
      silent = true,
    })
  end

  if km.finalize and cmds.finalize then
    vim.keymap.set("n", km.finalize, ":" .. cmds.finalize .. "<CR>", {
      desc = "Finalize (commit) accepted changes",
      silent = true,
    })
  end

  if km.amend and cmds.amend then
    vim.keymap.set("n", km.amend, ":" .. cmds.amend .. "<CR>", {
      desc = "Amend (keep message) to previous commit",
      silent = true,
    })
  end

  if km.amend_edit and cmds.amend then
    vim.keymap.set("n", km.amend_edit, ":" .. cmds.amend .. "!<CR>", {
      desc = "Amend (edit message) to previous commit",
      silent = true,
    })
  end

  if km.abort and cmds.abort then
    vim.keymap.set("n", km.abort, ":" .. cmds.abort .. "<CR>", {
      desc = "Abort (discard) rejected changes",
      silent = true,
    })
  end

  -- Diffview keymaps
  if km.diffview_open then
    vim.keymap.set("n", km.diffview_open, ":DiffviewOpen<CR>", {
      desc = "Open Diffview",
      silent = true,
    })
  end

  if km.diffview_close then
    vim.keymap.set("n", km.diffview_close, ":DiffviewClose<CR>", {
      desc = "Close Diffview",
      silent = true,
    })
  end

  if km.diffview_history then
    vim.keymap.set("n", km.diffview_history, ":DiffviewFileHistory %<CR>", {
      desc = "File history",
      silent = true,
    })
  end
end

return M

