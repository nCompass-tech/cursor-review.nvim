# cursor-review.nvim

Review Cursor Agent changes in Neovim with a hunk-by-hunk accept/reject workflow.

This plugin integrates [gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim) and [diffview.nvim](https://github.com/sindrets/diffview.nvim) to provide a VS Code Cursor-like experience for reviewing AI-generated code changes directly in Neovim.

## Features

- **Checkpoint commits** before running Cursor Agent
- **Diffview integration** for reviewing all changes at once
- **Gitsigns integration** for hunk-level staging and resetting
- **Floating dialogs** for commit messages (powered by nui.nvim)
- **Amend support** for iterative changes
- **Fully configurable** keymaps and commands

## Requirements

- Neovim >= 0.8
- [gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim)
- [diffview.nvim](https://github.com/sindrets/diffview.nvim)
- [nui.nvim](https://github.com/MunifTanjim/nui.nvim)
- [plenary.nvim](https://github.com/nvim-lua/plenary.nvim)
- [nvim-web-devicons](https://github.com/nvim-tree/nvim-web-devicons) (optional, for icons)

## Installation

### lazy.nvim

```lua
{
  "yourusername/cursor-review.nvim",
  dependencies = {
    "lewis6991/gitsigns.nvim",
    "sindrets/diffview.nvim",
    "MunifTanjim/nui.nvim",
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
  },
  config = function()
    require("cursor-review").setup()
  end,
}
```

### packer.nvim

```lua
use {
  "yourusername/cursor-review.nvim",
  requires = {
    "lewis6991/gitsigns.nvim",
    "sindrets/diffview.nvim",
    "MunifTanjim/nui.nvim",
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
  },
  config = function()
    require("cursor-review").setup()
  end,
}
```

### vim-plug

```vim
Plug 'lewis6991/gitsigns.nvim'
Plug 'sindrets/diffview.nvim'
Plug 'MunifTanjim/nui.nvim'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-tree/nvim-web-devicons'
Plug 'yourusername/cursor-review.nvim'
```

Then in your Lua config:

```lua
require("cursor-review").setup()
```

## Usage

### Typical Workflow

1. **Create a checkpoint** before running Cursor Agent:
   ```
   :CursorCheckpoint
   ```

2. **Run Cursor Agent** (let it make changes to your files)

3. **Review changes** in diffview:
   ```
   :CursorReview
   ```

4. **Navigate and accept/reject hunks:**
   - `]c` / `[c` - Navigate between hunks
   - `<leader>hs` - Accept (stage) a hunk
   - `<leader>hr` - Reject (reset) a hunk
   - In diffview file panel: `s` to stage, `X` to restore

5. **Commit accepted changes:**
   ```
   :CursorFinalize
   ```
   (Opens a floating dialog for your commit message)

6. **Or amend to previous commit:**
   ```
   :CursorAmend     " Keep existing message
   :CursorAmend!    " Edit message
   ```

## Commands

| Command | Description |
|---------|-------------|
| `:CursorCheckpoint [msg]` | Create a checkpoint commit before running Cursor Agent |
| `:CursorReview` | Open diffview to review all changes |
| `:CursorFinalize` | Open floating dialog to commit staged changes |
| `:CursorAmend` | Amend staged changes to previous commit (keep message) |
| `:CursorAmend!` | Amend staged changes with new message (floating dialog) |
| `:CursorAbort` | Discard all unstaged (rejected) changes |

## Default Keymaps

### Workflow Commands

| Key | Action |
|-----|--------|
| `<leader>cp` | Create checkpoint |
| `<leader>cr` | Review changes (open diffview) |
| `<leader>cf` | Finalize (commit staged changes) |
| `<leader>cm` | Amend (keep message) |
| `<leader>cM` | Amend (edit message) |
| `<leader>ca` | Abort (discard unstaged) |

### Hunk Navigation (gitsigns)

| Key | Action |
|-----|--------|
| `]c` / `[c` | Next/previous hunk |
| `<leader>hp` | Preview hunk |
| `<leader>hs` | Stage (accept) hunk |
| `<leader>hr` | Reset (reject) hunk |
| `<leader>hu` | Undo last stage |
| `<leader>hS` | Stage entire buffer |
| `<leader>hR` | Reset entire buffer |
| `<leader>hb` | Blame line |
| `<leader>tb` | Toggle line blame |
| `<leader>hd` | Diff against index |
| `<leader>hD` | Diff against last commit |

### Diffview

| Key | Action |
|-----|--------|
| `<leader>dv` | Open Diffview |
| `<leader>dc` | Close Diffview |
| `<leader>dh` | File history |

### Diffview File Panel

| Key | Action |
|-----|--------|
| `j` / `k` | Navigate entries |
| `<CR>` or `o` | Select entry |
| `s` or `-` | Stage/unstage file |
| `X` | Restore (reject) file |
| `S` | Stage all |
| `U` | Unstage all |
| `q` | Close diffview |

## Configuration

```lua
require("cursor-review").setup({
  -- Keymap configuration
  keymaps = {
    enable = true,  -- Set to false to disable all keymaps

    -- Workflow commands
    checkpoint = "<leader>cp",
    review = "<leader>cr",
    finalize = "<leader>cf",
    amend = "<leader>cm",
    amend_edit = "<leader>cM",
    abort = "<leader>ca",

    -- Diffview shortcuts
    diffview_open = "<leader>dv",
    diffview_close = "<leader>dc",
    diffview_history = "<leader>dh",

    -- Gitsigns hunk operations
    next_hunk = "]c",
    prev_hunk = "[c",
    stage_hunk = "<leader>hs",
    reset_hunk = "<leader>hr",
    preview_hunk = "<leader>hp",
    undo_stage = "<leader>hu",
    stage_buffer = "<leader>hS",
    reset_buffer = "<leader>hR",
    blame_line = "<leader>hb",
    toggle_blame = "<leader>tb",
    diff_this = "<leader>hd",
    diff_last = "<leader>hD",
  },

  -- Command names (set to false to disable a command)
  commands = {
    checkpoint = "CursorCheckpoint",
    review = "CursorReview",
    finalize = "CursorFinalize",
    amend = "CursorAmend",
    abort = "CursorAbort",
  },

  -- UI options for floating dialogs
  ui = {
    border = "rounded",  -- "single", "double", "rounded", "solid", "shadow"
    width = 60,
    commit_title = " Commit ",
    amend_title = " Amend Commit ",
  },

  -- Gitsigns options (passed through to gitsigns.setup)
  gitsigns = {
    signs = {
      add = { text = "+" },
      change = { text = "~" },
      delete = { text = "_" },
      topdelete = { text = "‾" },
      changedelete = { text = "~" },
    },
    -- ... other gitsigns options
  },

  -- Diffview options
  diffview = {
    enhanced_diff_hl = true,
    use_icons = true,
    layout = "diff2_horizontal",  -- or "diff2_vertical"
    file_panel_width = 35,
  },

  -- Notification settings
  notifications = {
    enable = true,
    verbose = true,  -- Show help text on :CursorReview
  },
})
```

## API

The plugin also exposes a Lua API for programmatic use:

```lua
local cr = require("cursor-review")

-- Check if initialized
cr.is_initialized()

-- Get current config
cr.get_config()

-- Programmatic commands
cr.checkpoint("my checkpoint message")
cr.review()
cr.finalize()
cr.amend()        -- Keep message
cr.amend(true)    -- Edit message
cr.abort()
```

## License

MIT License - see [LICENSE](LICENSE) for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Acknowledgments

- [gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim) by Lewis Russell
- [diffview.nvim](https://github.com/sindrets/diffview.nvim) by Sindre T. Strøm
- [nui.nvim](https://github.com/MunifTanjim/nui.nvim) by Munif Tanjim

