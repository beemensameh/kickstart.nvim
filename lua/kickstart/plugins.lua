-- Install `lazy.nvim` plugin manager
--    See `:help lazy.nvim.txt` or https://github.com/folke/lazy.nvim for more info
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  vim.fn.system { 'git', 'clone', '--depth=1', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
end
vim.opt.rtp:prepend(lazypath)

-- Configure and install plugins
--
--  To check the current status of your plugins, run
--    :Lazy
--
--  You can press `?` in this menu for help. Use `:q` to close the window
--
--  To update plugins you can run
--    :Lazy update
--
-- NOTE: Here is where you install your plugins.
require('lazy').setup({
  {   -- Useful plugin to show you pending keybinds.
    'folke/which-key.nvim', version = '*', event = 'VimEnter',
  },
  {   -- Fuzzy Finder (files, lsp, etc)
    'nvim-telescope/telescope.nvim',
    event = 'VimEnter',
    branch = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
    },
  },
  {   -- Collection of various small independent plugins/modules
    'echasnovski/mini.nvim', version = '*',
    config = function()
      -- Better Around/Inside textobjects
      --
      -- Examples:
      --  - va)  - [V]isually select [A]round [)]paren
      --  - yinq - [Y]ank [I]nside [N]ext [']quote
      --  - ci'  - [C]hange [I]nside [']quote
      require('mini.ai').setup { n_lines = 500 }

      -- Add/delete/replace surroundings (brackets, quotes, etc.)
      --
      -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
      -- - sd'   - [S]urround [D]elete [']quotes
      -- - sr)'  - [S]urround [R]eplace [)] [']
      require('mini.surround').setup()

      -- Simple and easy statusline.
      --  You could remove this setup call if you don't like it,
      --  and try some other statusline plugin
      local statusline = require 'mini.statusline'
      -- set use_icons to true if you have a Nerd Font
      statusline.setup { use_icons = vim.g.have_nerd_font }

      -- You can configure sections in the statusline by overriding their
      -- default behavior. For example, here we set the section for
      -- cursor location to LINE:COLUMN
      ---@diagnostic disable-next-line: duplicate-set-field
      statusline.section_location = function()
        return '%2l:%-2v'
      end

      -- ... and there is more!
      --  Check out: https://github.com/echasnovski/mini.nvim
    end,
  },

  'tpope/vim-sleuth',   -- Detect tabstop and shiftwidth automatically
  { 'numToStr/Comment.nvim', event = 'VimEnter', opts = {} },
  { 'folke/todo-comments.nvim', version = '*', event = 'VimEnter', dependencies = { 'nvim-lua/plenary.nvim' }, opts = { signs = false } },
  {   -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    opts = {
      ensure_installed = { 'bash', 'html', 'lua', 'markdown', 'go', 'python' },
      -- Autoinstall languages that are not installed
      auto_install = true,
      highlight = {
        enable = true,
        -- Some languages depend on vim's regex highlighting system (such as Ruby) for indent rules.
        --  If you are experiencing weird indenting issues, add the language to
        --  the list of additional_vim_regex_highlighting and disabled languages for indent.
        -- additional_vim_regex_highlighting = { 'ruby' },
        disable = function(lang, buf)
          local max_filesize = 100 * 1024 -- 100 KB
          local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
          if ok and stats and stats.size > max_filesize then
            return true
          end
        end,
      },
      indent = { enable = true, disable = { 'ruby' } },
    },
    config = function(_, opts)
      -- [[ Configure Treesitter ]] See `:help nvim-treesitter`

      -- Prefer git instead of curl in order to improve connectivity in some environments
      require('nvim-treesitter.install').prefer_git = true
      ---@diagnostic disable-next-line: missing-fields
      require('nvim-treesitter.configs').setup(opts)

      -- There are additional nvim-treesitter modules that you can use to interact
      -- with nvim-treesitter. You should go explore a few and see what interests you:
      --
      --    - Incremental selection: Included, see `:help nvim-treesitter-incremental-selection-mod`
      --    - Show your current context: https://github.com/nvim-treesitter/nvim-treesitter-context
      --    - Treesitter + textobjects: https://github.com/nvim-treesitter/nvim-treesitter-textobjects
    end,
  },
  { -- Undo/Redo tree
    "mbbill/undotree",
    enabled = true,
    event = 'VimEnter',
    config = function ()
      vim.keymap.set('n', '<leader>tu', vim.cmd.UndotreeToggle, { desc = '[T]oggle [U]ndotree' })
    end
  },
  { -- LSP
    {
      'VonHeikemen/lsp-zero.nvim',
      branch = 'v3.x',
      dependencies = {
        {'neovim/nvim-lspconfig', version = '*'},
        'williamboman/mason.nvim',
        'williamboman/mason-lspconfig.nvim',
        'WhoIsSethDaniel/mason-tool-installer.nvim',
        { 'j-hui/fidget.nvim', opts = {} },
        'hrsh7th/cmp-nvim-lsp',
        'hrsh7th/nvim-cmp',
        'L3MON4D3/LuaSnip',
      },
      config = function()
        local lsp_zero = require('lsp-zero')
        lsp_zero.on_attach(function(client, bufnr)
          lsp_zero.default_keymaps({buffer = bufnr})
        end)

        require('mason').setup({})
        require('mason-lspconfig').setup({
          ensure_installed = {'gopls', 'pylsp'},
          handlers = {
            lsp_zero.default_setup,
            function(server_name)
              require('lspconfig')[server_name].setup({})
            end,
          },
        })

        require('mason-tool-installer').setup { ensure_installed = ensure_installed }
        
        local cmp = require('cmp')
        cmp.setup({
          sources = {
            {name = 'nvim_lsp'},
          },
          mapping = {
            ['<C-y>'] = cmp.mapping.confirm({select = false}),
            ['<C-e>'] = cmp.mapping.abort(),
            ['<Up>'] = cmp.mapping.select_prev_item({behavior = 'select'}),
            ['<Down>'] = cmp.mapping.select_next_item({behavior = 'select'}),
            ['<C-p>'] = cmp.mapping(function()
              if cmp.visible() then
                cmp.select_prev_item({behavior = 'insert'})
              else
                cmp.complete()
              end
            end),
            ['<C-n>'] = cmp.mapping(function()
              if cmp.visible() then
                cmp.select_next_item({behavior = 'insert'})
              else
                cmp.complete()
              end
            end),
          },
          snippet = {
            expand = function(args)
              require('luasnip').lsp_expand(args.body)
            end,
          },
        })

        vim.api.nvim_create_autocmd("BufWritePre", {
          pattern = "*.go",
          callback = function()
            local params = vim.lsp.util.make_range_params()
            params.context = {only = {"source.organizeImports"}}
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
            vim.lsp.buf.format({async = false})
          end
        })
      end
    },
  }
}, {
    ui = {
      -- If you are using a Nerd Font: set icons to an empty table which will use the
      -- default lazy.nvim defined Nerd Font icons, otherwise define a unicode icons table
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
        lazy = '💤 ',
      },
    },
  })

-- vim: ts=2 sts=2 sw=2 et
