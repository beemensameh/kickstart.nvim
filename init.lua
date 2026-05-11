--globle
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.opt.undofile = true
vim.schedule(function()
  vim.opt.clipboard = 'unnamedplus'
end)

-- UI
vim.opt.mouse = 'a'
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.list = true
vim.opt.scrolloff = 10

-- numbers
vim.opt.number = true
vim.opt.relativenumber = true

-- search
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- edit
vim.opt.tabstop = 4
vim.opt.shiftwidth = 0  -- if zero, will map on tapstop
vim.opt.softtabstop = 0 -- if zero, will map on tapstop
vim.opt.smartindent = true
vim.opt.wrap = false

-- diagnostic
vim.diagnostic.enable = true
vim.diagnostic.config({
  virtual_text = true,
})

-- keymap
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')
-- replace without remove yank buffer
vim.keymap.set('x', '<leader>p', '"_dP')
-- move lines up and down
vim.keymap.set('n', '<A-j>', 'ddjP')
vim.keymap.set('n', '<A-k>', 'ddkP')
-- termianl keymap
vim.keymap.set('n', '<leader>tt', '<cmd>:split term://bash<CR>', { desc = '[T]oggle [T]erminal', silent = true })
vim.keymap.set('t', '<Esc>', [[<C-\><C-n>]], { desc = 'Exit terminal mode' })

vim.keymap.set('n', '<leader>e', vim.cmd.Ex, { desc = 'Back to explorer' })

-- autocmd
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- add lazy.nvim
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system({ 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out,                            "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- lazy.nvim keymaps
vim.keymap.set('n', '<leader>lh', require('lazy').home, { desc = '[L]azy [H]ome' })
vim.keymap.set('n', '<leader>lc', require('lazy').check, { desc = '[L]azy [C]heck' })
vim.keymap.set('n', '<leader>lx', require('lazy').clean, { desc = '[L]azy Clean [X]' })
vim.keymap.set('n', '<leader>ls', require('lazy').sync, { desc = '[L]azy [S]ync' })
vim.keymap.set('n', '<leader>lu', require('lazy').update, { desc = '[L]azy [U]pdate' })

-- -- to resort imports when saving
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.go",
  callback = function()
    local params = vim.lsp.util.make_range_params(0, "uft-16")
    params.context = { only = { "source.organizeImports" } }
    -- buf_request_sync defaults to a 1000ms timeout. Depending on your
    -- machine and codebase, you may want longer. Add an additional
    -- argument after params if you find that you have to write the file
    -- twice for changes to be saved.
    -- E.g., vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, 3000)
    local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params)
    for cid, res in pairs(result or {}) do
      for _, r in pairs(res.result or {}) do
        if r.edit then
          local enc = (vim.lsp.get_client_by_id(cid) or {}).offset_encoding or "utf-16"
          vim.lsp.util.apply_workspace_edit(r.edit, enc)
        end
      end
    end
    vim.lsp.buf.format({ async = false })
  end
})

--
local plugins = {
  {
    "catppuccin/nvim",
    event = "VeryLazy",
    name = "catppuccin",
    config = function()
      require("catppuccin").setup({
        flavor = "latte",
        background = { -- :h background
          light = "latte",
          dark = "latte",
        },
      })
      vim.cmd.colorscheme("catppuccin")
    end
  },
  {
    'folke/which-key.nvim',
    event = "VeryLazy",
    opts = {
      preset = "helix",
      icons = {
        mappings = false,
      },
    },
    config = function(_, opts)
      local whichkey = require('which-key')
      whichkey.setup(opts)
      whichkey.add {
        { '<leader>l', group = '[L]azy' },
        { '<leader>s', group = '[S]earch' },
        { '<leader>t', group = '[T]oggle' },
        { '<leader>c', group = '[C]ode' },
      }
    end,
  },
  {
    'nvim-telescope/telescope.nvim',
    event = "VeryLazy",
    version = '0.2.x',
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    config = function()
      -- Search in hidden files(dot files)
      require("telescope").setup({
        pickers = {
          find_files = {
            -- hidden = true, -- will still show the inside of `.git/` as it's not `.gitignore`d.
            find_command = { "rg", "--files", "--hidden", "--glob", "!**/.git/*", "--glob", "!**/node_modules/*", "--smart-case" },
          },
          colorscheme = {
            enable_preview = true
          }
        },

      })

      local builtin = require('telescope.builtin')
      -- vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
      vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
      vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
      vim.keymap.set('n', '<C-p>', builtin.find_files, { desc = 'Search Files' })
      vim.keymap.set('n', '<leader>st', builtin.builtin, { desc = '[S]earch [T]elescope Commands' })
      vim.keymap.set('n', '<leader>sc', builtin.commands, { desc = '[S]earch plugin/user [C]ommands' })
      vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep workspace files' })
      vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
      vim.keymap.set('n', '<leader> ', builtin.buffers, { desc = '[ ]Search opened files' })
      vim.keymap.set('n', '<leader>sw', builtin.current_buffer_fuzzy_find,
        { desc = '[w] Fuzzily search in current file' })

      vim.keymap.set('n', '<leader>s.', function()
        builtin.live_grep {
          grep_open_files = true,
          prompt_title = 'Live Grep in Open Files',
        }
      end, { desc = '[S]earch [.] in Open Files' })

      -- Shortcut for searching your Neovim configuration files
      vim.keymap.set('n', '<leader>sn', function()
        builtin.find_files { cwd = vim.fn.stdpath 'config' }
      end, { desc = '[S]earch [N]eovim files' })
    end,
  },
  {
    'lewis6991/gitsigns.nvim',
    version = '*',
    event = "BufReadPost",
    opts = {
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
    },
  },
  {
    'sindrets/diffview.nvim',
    event = "BufReadPost",
    config = function(_, opts)
      local diffview = require('diffview')
      opts.use_icons = false
      diffview.setup(opts)
      vim.keymap.set('n', '<leader>td', function()
        local current_buf = vim.api.nvim_buf_get_name(0)
        if string.find(current_buf, "diffview://") ~= nil then
          vim.cmd("DiffviewClose")
        else
          vim.cmd("DiffviewOpen")
        end
      end, { desc = '[T]oggle [D]iffview' })
    end
  },
  {
    "mbbill/undotree",
    event = 'BufReadPost',
    config = function()
      vim.keymap.set('n', '<leader>tu', vim.cmd.UndotreeToggle, { desc = '[T]oggle [U]ndotree' })
    end
  },
  {
    "stevearc/oil.nvim",
    lazy = false,
    config = function()
      require('oil').setup({
        columns = {
          "icon",
          "permissions",
          -- "size",
          -- "mtime",
        },
        view_options = {
          -- Show files and directories that start with "."
          show_hidden = true,
        },
        delete_to_trash = true,
        use_default_keymaps = true,
      })
      vim.keymap.set("n", "<leader>.", "<CMD>Oil<CR>", { desc = "Open parent directory" })
    end
  },
  {
    "matze/vim-move",
    enabled = false,
    event = { "BufReadPost", "BufNewFile" },
  },
  {
    "neovim/nvim-lspconfig",
    ft = { 'go', 'gomod', 'gowork', 'gotmpl', 'python', 'lua', 'dockerfile' },
    version = "*",
    dependencies = {
      { 'mason-org/mason.nvim', config = true },
      'hrsh7th/nvim-cmp',
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-path',
    },
    config = function()
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc)
            vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end

          map('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
          map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
          map('gr', vim.lsp.buf.references, '[G]oto [R]eferences')
          map('gi', vim.lsp.buf.implementation, '[G]oto [I]mplementation')
          map('rn', vim.lsp.buf.rename, '[R]e[n]ame')
          -- map('<leader>D', vim.lsp.buf.type_definition, 'Type [D]efinition')
          -- map('<leader>ds', vim.lsp.buf.document_symbol, '[D]ocument [S]ymbols')
          -- map('<leader>ws', vim.lsp.buf.dynamic_workspace_symbol, '[W]orkspace [S]ymbols').
          -- map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

          -- The following two autocommands are used to highlight references of the
          -- word under your cursor when your cursor rests there for a little while.
          --    See `:help CursorHold` for information about when this is executed
          --
          -- When you move your cursor, the highlights will be cleared (the second autocommand).
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
            local highlight_augroup = vim.api.nvim_create_augroup('lsp-highlight', { clear = false })
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.clear_references,
            })

            vim.api.nvim_create_autocmd('LspDetach', {
              group = vim.api.nvim_create_augroup('lsp-detach', { clear = true }),
              callback = function(event2)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds { group = 'lsp-highlight', buffer = event2.buf }
              end,
            })
          end

          -- The following code creates a keymap to toggle inlay hints in your
          -- code, if the language server you are using supports them
          --
          -- This may be unwanted, since they displace some of your code
          if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
            map('<leader>th', function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
            end, '[T]oggle Inlay [H]ints')
          end
        end,
      })

      -- LSP servers and clients are able to communicate to each other what features they support.
      --  By default, Neovim doesn't support everything that is in the LSP specification.
      --  When you add nvim-cmp, luasnip, etc. Neovim now has *more* capabilities.
      --  So, we create new capabilities with nvim cmp, and then broadcast that to the servers.
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())
      local servers = {
        gopls = {
          filetypes = { 'go', 'gomod', 'gowork', 'gotmpl' },
          settings = {
            gopls = {
              gofumpt = true,
              completeUnimported = true,
              usePlaceholders = true,
              analyses = {
                unusedparams = true,
              },
            },
          },
        },
        -- Instal node https://nodejs.org/en/download/
        pyright = {
          filetypes = { "python" },
          settings = {
            python = {
              pythonPath = './.venv/bin/python',
            }
          }
        },
        lua_ls = {
          -- Command and arguments to start the server.
          cmd = { 'lua-language-server' },
          -- Filetypes to automatically attach to.
          filetypes = { 'lua' },
          -- Sets the "workspace" to the directory where any of these files is found.
          -- Files that share a root directory will reuse the LSP server connection.
          -- Nested lists indicate equal priority, see |vim.lsp.Config|.
          root_markers = { { '.luarc.json', '.luarc.jsonc' }, '.git' },
          -- Specific settings to send to the server. The schema is server-defined.
          -- Example: https://raw.githubusercontent.com/LuaLS/vscode-lua/master/setting/schema.json
          settings = {
            Lua = {
              runtime = {
                version = "LuaJIT"
              },
              diagnostics = {
                globals = { "vim", "require" },
              },
              workspace = {
                library = {
                  vim.api.nvim_get_runtime_file("", true),
                },
                telemetry = {
                  enable = false,
                },
                maxPreload = 100000,
                preloadFileSize = 10000,
              },
            },
          },
        },
        stylua = nil,
        dockerls = nil,
      }

      require('mason').setup({
        ui = {
          icons = {
            package_installed = "✓",
            package_pending = "➜",
            package_uninstalled = "✗"
          },
        },
      })

      vim.lsp.config("*", { capabilities = capabilities })
      for key, value in pairs(servers or {}) do
        if value ~= nil then
          vim.lsp.config(key, value)
        end
        vim.lsp.enable(key)
      end

      local cmp = require('cmp')
      cmp.setup({

        completion = { completeopt = 'menu,menuone,noinsert' },
        mapping = cmp.mapping.preset.insert({
          ['<C-n>'] = cmp.mapping.select_next_item(),
          ['<C-p>'] = cmp.mapping.select_prev_item(),
          --['<Tab>'] = cmp.mapping.select_next_item(),
          --['<S-Tab>'] = cmp.mapping.select_prev_item(),
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<C-e>'] = cmp.mapping.abort(),
          ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
          -- ['<C-y>'] = cmp.mapping.confirm { select = true },
        }),
        sources = {
          {
            name = 'lazydev',
            -- set group index to 0 to skip loading LuaLS completions as lazydev recommends it
            group_index = 0,
          },
          { name = 'nvim_lsp' },
          { name = 'path' },
        },
      })
    end,
  },
  {
    'stevearc/conform.nvim',
    version = "*",
    ft = { "python", "lua" },
    event = 'BufWritePre',
    keys = {
      {
        '<leader>cf',
        function()
          require('conform').format { async = true, lsp_fallback = true }
        end,
        mode = '',
        desc = '[C]ode [F]ormat buffer',
      },
    },
    opts = {
      notify_on_error = true,
      format_on_save = function(bufnr)
        -- You can specify filetypes to autoformat on save here
        local enable_filetypes = nil
        local disable_filetypes = { c = true, cpp = true }
        if enable_filetypes ~= nil then
          if enable_filetypes[vim.bo[bufnr].filetype] then
            return { timeout_ms = 500, lsp_format = "fallback" }
          end
        elseif disable_filetypes ~= nil then
          if not disable_filetypes[vim.bo[bufnr].filetype] then
            return { timeout_ms = 500, lsp_format = "fallback" }
          end
        end
      end,
      formatters_by_ft = {
        python = { "ruff" },
        lua = { "stylya" },
        -- You can use 'stop_after_first' to run the first available formatter from the list
        -- javascript = { "prettierd", "prettier", stop_after_first = true },
      },
    },
  },
}

local opts = {
  defaults = { lazy = true },
  ui = {
    icons = {
      cmd = '⌘',
      config = '🛠',
      event = '📅',
      ft = '📂',
      init = '⚙',
      keys = '🗝',
      plugin = '🔌',
      runtime = '💻',
      require = '🌙',
      source = '📄',
      start = '🚀',
      task = '📌',
      lazy = '💤',
    },
  },
}

require('lazy').setup(plugins, opts)

-- ### Config the status bar ###
-- internal state for toggles
local state = {
  show_path = true,
  show_branch = true,
}

-- config for placeholders + highlighting
local config = {
  icons = {
    path_hidden = "",
    branch_hidden = "",
  },
  placeholder_hl = "StatusLineDim",
}

-- helper to wrap text in a statusline highlight group
local function hl(group, text)
  return string.format("%%#%s#%s%%*", group, text)
end

-- create and link the highlight group(s)
vim.api.nvim_set_hl(0, config.placeholder_hl, {}) -- create if missing
vim.api.nvim_set_hl(0, config.placeholder_hl, { link = "Comment" })

local function filepath()
  local fpath = vim.fn.fnamemodify(vim.fn.expand "%", ":~:.:h")

  if fpath == "" or fpath == "." then
    return ""
  end

  if state.show_path then
    return string.format("%%<%s/", fpath)
  end

  return hl(config.placeholder_hl, config.icons.path_hidden .. "/")
end

local function git()
  local git_info = vim.b.gitsigns_status_dict
  if not git_info or git_info.head == "" then
    return ""
  end

  local head    = git_info.head
  local added   = git_info.added and (" +" .. git_info.added) or ""
  local changed = git_info.changed and (" ~" .. git_info.changed) or ""
  local removed = git_info.removed and (" -" .. git_info.removed) or ""
  if git_info.added == 0 then added = "" end
  if git_info.changed == 0 then changed = "" end
  if git_info.removed == 0 then removed = "" end

  if not state.show_branch then
    head = hl(config.placeholder_hl, config.icons.branch_hidden)
  end

  return table.concat({
    "[ ",
    head,
    added, changed, removed,
    "]",
  })
end

Statusline = {}

function Statusline.active()
  return table.concat {
    "[", filepath(), "%t] ",
    git(),
    "%=",
    "%y [%P %l:%c]"
  }
end

function Statusline.inactive()
  return " %t"
end

function Statusline.toggle_path()
  state.show_path = not state.show_path
  vim.cmd("redrawstatus")
end

function Statusline.toggle_branch()
  state.show_branch = not state.show_branch
  vim.cmd("redrawstatus")
end

vim.keymap.set("n", "<leader>tp", function() Statusline.toggle_path() end, { desc = "Toggle statusline path" })
vim.keymap.set("n", "<leader>tb", function() Statusline.toggle_branch() end, { desc = "Toggle statusline git branch" })

local group = vim.api.nvim_create_augroup("Statusline", { clear = true })

vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter" }, {
  group = group,
  desc = "Activate statusline on focus",
  callback = function()
    vim.opt_local.statusline = "%!v:lua.Statusline.active()"
  end,
})

vim.api.nvim_create_autocmd({ "WinLeave", "BufLeave" }, {
  group = group,
  desc = "Deactivate statusline when unfocused",
  callback = function()
    vim.opt_local.statusline = "%!v:lua.Statusline.inactive()"
  end,
})

-- vim: set ft=lua ts=2 sts=2 sw=2 et:
