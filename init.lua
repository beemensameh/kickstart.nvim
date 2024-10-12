-- globle
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.g.have_nerd_font = false

vim.opt.undofile = true
vim.schedule(function()
  vim.opt.clipboard = 'unnamedplus'
end)

-- UI
vim.opt.mouse = 'a'
vim.opt.showmode = false
vim.opt.splitbelow = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
vim.opt.scrolloff = 10
vim.cmd.colorscheme('habamax')
vim.opt.list = true

-- numbers
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.signcolumn = 'yes:2'

-- search
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = true
vim.opt.incsearch = true

-- edit
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.smartindent = true
vim.opt.wrap = false

-- performance
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300

-- keymap
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')
-- past without remove yank buffer
vim.keymap.set('x', '<leader>p', '"_dP')
-- move line up and down
vim.keymap.set('x', '<ALT-j>', 'ddjp')
vim.keymap.set('x', '<ALT-k>', 'ddkp')

-- autocmd
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.go",
  callback = function()
    local params = vim.lsp.util.make_range_params()
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

local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system({ 'git', 'clone', '--filter=blob:none', lazyrepo, lazypath })
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

vim.keymap.set('n', '<leader>e', vim.cmd.Ex, { desc = 'Back to explorer' })
vim.keymap.set('n', '<leader>lh', require('lazy').home, { desc = '[L]azy [H]ome' })
vim.keymap.set('n', '<leader>lc', require('lazy').check, { desc = '[L]azy [C]heck' })
vim.keymap.set('n', '<leader>lx', require('lazy').clean, { desc = '[L]azy Clean [X]' })
vim.keymap.set('n', '<leader>ls', require('lazy').sync, { desc = '[L]azy [S]ync' })
vim.keymap.set('n', '<leader>lu', require('lazy').update, { desc = '[L]azy [U]pdate' })

require('lazy').setup({
  {
    'goolord/alpha-nvim',
    lazy = false,
    dependencies = { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
    config = function()
      require('alpha').setup(require 'alpha.themes.startify'.config)
    end
  },
  {
    'echasnovski/mini.nvim',
    version = '*',
    config = function()
      require('mini.ai').setup({ n_lines = 500 })
      require('mini.surround').setup()
      require('mini.pairs').setup()
      require('mini.move').setup()
      require('mini.statusline').setup({ use_icons = vim.g.have_nerd_font })
      require('mini.git').setup()
    end,
  },
  {
    'folke/which-key.nvim',
    version = '*',
    event = "VeryLazy",
    opts = {
      preset = "helix",
      icons = {
        mappings = false,
      },
    },
    config = function(_, opts)
      require('which-key').setup(opts)
      require('which-key').add {
        { '<leader>c', group = '[C]ode' },
        { '<leader>d', group = '[D]ocument' },
        { '<leader>l', group = '[L]azy' },
        { '<leader>r', group = '[R]ename' },
        { '<leader>s', group = '[S]earch' },
        { '<leader>t', group = '[T]oggle' },
        { '<leader>w', group = '[W]orkspace' },
        { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } },
      }
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
    'nvim-telescope/telescope.nvim',
    cmd = "Telescope",
    lazy = false,
    version = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
    },
    config = function()
      -- Search in hidden files(dot files)
      local telescope = require("telescope")
      local telescopeConfig = require("telescope.config")
      local builtin = require('telescope.builtin')

      -- Clone the default Telescope configuration
      local vimgrep_arguments = { unpack(telescopeConfig.values.vimgrep_arguments) }

      -- I want to search in hidden/dot files.
      table.insert(vimgrep_arguments, "--hidden")
      -- I don't want to search in the `.git` directory.
      table.insert(vimgrep_arguments, "--glob")
      table.insert(vimgrep_arguments, "!**/.git/*")
      telescope.setup({
        defaults = {
          -- `hidden = true` is not supported in text grep commands.
          vimgrep_arguments = vimgrep_arguments,
        },
        pickers = {
          find_files = {
            -- `hidden = true` will still show the inside of `.git/` as it's not `.gitignore`d.
            find_command = { "rg", "--files", "--hidden", "--glob", "!**/.git/*" },
          },
        },
      })

      vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
      vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
      vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
      vim.keymap.set('n', '<C-p>', builtin.find_files, { desc = '[S]earch [F]iles' })
      vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
      vim.keymap.set('n', '<leader>sc', builtin.commands, { desc = '[S]earch [C]ommands' })
      vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
      vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
      vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
      vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
      vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
      vim.keymap.set('n', '<leader> ', builtin.buffers, { desc = '[S]earch existing [B]uffers' })

      -- Slightly advanced example of overriding default behavior and theme
      vim.keymap.set('n', '<leader>/', function()
        -- You can pass additional configuration to Telescope to change the theme, layout, etc.
        builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
          winblend = 10,
          previewer = false,
        })
      end, { desc = '[/] Fuzzily search in current buffer' })

      -- It's also possible to pass additional configuration options.
      --  See `:help telescope.builtin.live_grep()` for information about particular keys
      vim.keymap.set('n', '<leader>s/', function()
        builtin.live_grep {
          grep_open_files = true,
          prompt_title = 'Live Grep in Open Files',
        }
      end, { desc = '[S]earch [/] in Open Files' })

      -- Shortcut for searching your Neovim configuration files
      vim.keymap.set('n', '<leader>sn', function()
        builtin.find_files { cwd = vim.fn.stdpath 'config' }
      end, { desc = '[S]earch [N]eovim files' })
    end,
  },
  {
    'hrsh7th/nvim-cmp',
    dependencies = {
      'hrsh7th/cmp-path',
      {
        "L3MON4D3/LuaSnip",
        event = "BufReadPost",
        version = "v2.*",
        -- install jsregexp (optional!).
        -- build = "make install_jsregexp"
      },
    },
    event = 'InsertEnter',
    config = function()
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
        snippet = {
          expand = function(args)
            require('luasnip').lsp_expand(args.body)
          end,
        },
      })
    end
  },
  {
    'neovim/nvim-lspconfig',
    enabled = false,
    event = "User FilePost",
    ft = { "go", "python", "lua" },
    version = "*",
    dependencies = {
      { 'williamboman/mason.nvim', config = true },
      'williamboman/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',
      'hrsh7th/cmp-nvim-lsp',
    },
    config = function()
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc)
            vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end

          map('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
          map('gr', vim.lsp.buf.references, '[G]oto [R]eferences')
          map('gI', vim.lsp.buf.implementation, '[G]oto [I]mplementation')
          map('<leader>D', vim.lsp.buf.type_definition, 'Type [D]efinition')
          map('<leader>ds', vim.lsp.buf.document_symbol, '[D]ocument [S]ymbols')
          -- map('<leader>ws', vim.lsp.buf.dynamic_workspace_symbol, '[W]orkspace [S]ymbols').
          map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
          map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
          map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

          -- The following two autocommands are used to highlight references of the
          -- word under your cursor when your cursor rests there for a little while.
          --    See `:help CursorHold` for information about when this is executed
          --
          -- When you move your cursor, the highlights will be cleared (the second autocommand).
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
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
          if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
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
        -- gopls = {
        --   -- cmd = { "gopls" },
        --   filetypes = { "go", "gomod", "gowork", "gotmpl" },
        --   -- root_dir = require("lspconfig.util").root_pattern("go.work", "go.mod", ".git"),
        --   settings = {
        --     gopls = {
        --       gofumpt = true,
        --       completeUnimported = true,
        --       usePlaceholders = true,
        --       analyses = {
        --         unusedparams = true,
        --       },
        --     },
        --   },
        -- },
        -- pyright = {
        --   filetypes = { "python" },
        --   settings = {
        --     python = {
        --       pythonPath = './.venv/bin/python',
        --     }
        --   }
        -- },
        lua_ls = {
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
                  vim.fn.expand "$VIMRUNTIME/lua",
                  vim.fn.expand "$VIMRUNTIME/lua/vim/lsp",
                  vim.fn.stdpath "data" .. "/lazy/ui/nvchad_types",
                  vim.fn.stdpath "data" .. "/lazy/lazy.nvim/lua/lazy",
                  "${3rd}/luv/library",
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
      }

      require('mason').setup()

      local ensure_installed = vim.tbl_keys(servers or {})
      -- vim.list_extend(ensure_installed, { 'ts_ls', 'dockerls' })
      require('mason-tool-installer').setup { ensure_installed = ensure_installed }

      require('mason-lspconfig').setup {
        handlers = {
          function(server_name)
            local server = servers[server_name] or {}
            -- This handles overriding only values explicitly passed
            -- by the server configuration above. Useful when disabling
            -- certain features of an LSP (for example, turning off formatting for ts_ls)
            server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
            require('lspconfig')[server_name].setup(server)
          end,
        },
      }
    end,
  },
  {
    'stevearc/conform.nvim',
    version = "*",
    ft = { "python", "lua" },
    event = 'BufWritePre',
    cmd = 'ConformInfo',
    keys = {
      {
        '<leader>f',
        function()
          require('conform').format { async = true, lsp_fallback = true }
        end,
        mode = '',
        desc = '[F]ormat buffer',
      },
    },
    opts = {
      notify_on_error = true,
      format_on_save = function(bufnr)
        -- Disable "format_on_save lsp_fallback" for languages that don't
        -- have a well standardized coding style. You can add additional
        -- languages here or re-enable it for the disabled ones.
        local disable_filetypes = { c = true, cpp = true }
        return {
          timeout_ms = 500,
          lsp_fallback = not disable_filetypes[vim.bo[bufnr].filetype],
        }
      end,
      formatters_by_ft = {
        python = { "ruff" },
        lua = { "stylya" },
        -- You can use 'stop_after_first' to run the first available formatter from the list
        -- javascript = { "prettierd", "prettier", stop_after_first = true },
      },
    },
  },
  {
    'nvim-treesitter/nvim-treesitter',
    event = { "BufReadPost", "BufNewFile" },
    cmd = { "TSInstall", "TSBufEnable", "TSBufDisable", "TSModuleInfo" },
    build = ':TSUpdate',
    dependencies = {
      'nvim-treesitter/nvim-treesitter-context',
    },
    opts = {
      ensure_installed = {
        'html',
        'lua',
        'markdown',
        'go', 'gomod', 'gosum', 'gotmpl', 'gowork',
        'python',
        'json', 'jsonc',
        'yaml',
        'dockerfile',
      },
      sync_install = true,
      auto_install = true,
      highlight = {
        enable = true,
        disable = function(lang, buf)
          local max_filesize = 100 * 1024 -- 100 KB
          local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
          if ok and stats and stats.size > max_filesize then
            return true
          end
        end,
      },
      indent = { enable = true },
    },
    config = function(_, opts)
      ---@diagnostic disable-next-line: missing-fields
      require('nvim-treesitter.configs').setup(opts)
    end,
  },
  {
    "mbbill/undotree",
    event = 'BufReadPost',
    config = function()
      vim.keymap.set('n', '<leader>tu', vim.cmd.UndotreeToggle, { desc = '[T]oggle [U]ndotree' })
    end
  },
}, {
  defaults = { lazy = true, version = '*' },
  ui = {
    icons = vim.g.have_nerd_font and {} or {
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
})

-- vim: ts=2 sts=2 sw=2 et
