-- globle
-- Enable faster startup by caching compiled Lua modules
vim.loader.enable()

-- UI
vim.cmd.colorscheme('zellner')

-- lsp
vim.diagnostic.enable = true
vim.diagnostic.config({
  virtual_text = true,
})

-- performance
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300

local plugins = {
  {
    "vim-test/vim-test",
    enabled = false,
    dependencies = { "preservim/vimux" },
    ft = { 'go', 'python', 'php' },
    config = function()
      vim.keymap.set('n', '<leader>tn', ':TestNearest<CR>', { desc = '[T]est [N]earest' })
      vim.keymap.set('n', '<leader>tf', ':TestNearest<CR>', { desc = '[T]est [F]ile' })
      vim.keymap.set('n', '<leader>ts', ':TestNearest<CR>', { desc = '[T]est [S]uite' })
    end
  },
  {
    'mfussenegger/nvim-dap',
    enabled = false,
    -- lazy = false,
    version = "*",
    dependencies = {
      -- { 'mason-org/mason.nvim', config = true },
      -- "jay-babu/mason-nvim-dap.nvim",
      -- "theHamsta/nvim-dap-virtual-text",
      'rcarriga/nvim-dap-ui',
      'nvim-neotest/nvim-nio',
    },
    config = function(_, opt)
      local dap = require('dap')
      local dap_ui = require("dapui")
      dap_ui.setup(opt)

      dap.adapters.delve = function(callback, config)
        if config.mode == 'remote' and config.request == 'attach' then
          callback({
            type = 'server',
            host = config.host or '127.0.0.1',
            port = config.port or '38697'
          })
        else
          callback({
            type = 'server',
            port = '${port}',
            executable = {
              command = 'dlv',
              args = { 'dap', '-l', '127.0.0.1:${port}', '--log', '--log-output=dap' },
              detached = vim.fn.has("win32") == 0,
            }
          })
        end
      end

      dap.configurations.go = {
        {
          type = "delve",
          name = "Debug",
          request = "launch",
          program = "${file}"
        },
        {
          type = "delve",
          name = "Debug test", -- configuration for debugging test files
          request = "launch",
          mode = "test",
          program = "${file}"
        },
        -- works with go.mod packages and sub packages
        {
          type = "delve",
          name = "Debug test (go.mod)",
          request = "launch",
          mode = "test",
          program = "./${relativeFileDirname}"
        }
      }

      -- dap.listeners.after.event_initialized["dapui_config"] = function()
      --   dap_ui.open()
      -- end
      -- dap.listeners.after.event_terminated["dapui_config"] = function()
      --   dap_ui.close()
      -- end
      -- dap.listeners.before.event_exited["dapui_config"] = function()
      --   require("dapui").close()
      -- end
      vim.keymap.set('n', '<leader>db', dap.toggle_breakpoint, { desc = "[D]ap Toggle [B]reakpoint" })
      vim.keymap.set('n', '<leader><f5>', dap.continue, { desc = "[D]ap [S]tart or continue" })
      vim.keymap.set('n', '<leader>dt', dap_ui.toggle, { desc = "[D]ap UI [T]oggle" })
    end
  },
  {
    'nvim-treesitter/nvim-treesitter',
    config = function()
      require('nvim-treesitter.configs').setup(
        {
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
            enable = function(_, buf)
              local max_filesize = 100 * 1024 -- 100 KB
              local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
              if ok and stats and stats.size <= max_filesize then
                return true
              end
            end,
          },
          indent = { enable = true },
        }
      )
    end,
  },
}

-- vim: set ft=lua ts=2 sts=2 sw=2 et:
