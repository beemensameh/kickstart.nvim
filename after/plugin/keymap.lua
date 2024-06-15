-- [[ native keymap (remap) ]]
vim.keymap.set('n', '<leader>e', vim.cmd.Ex, { desc = 'Back to explorer' })

-- [[ which-key.nvim ]]
-- Document existing key chains
local has_which_key,which_key = pcall(require, "which-key")
if has_which_key then
  which_key.register {
    ['<leader>l'] = { name = '[L]azy', _ = 'which_key_ignore' },
    ['<leader>c'] = { name = '[C]ode', _ = 'which_key_ignore' },
    ['<leader>d'] = { name = '[D]ocument', _ = 'which_key_ignore' },
    ['<leader>r'] = { name = '[R]ename', _ = 'which_key_ignore' },
    ['<leader>s'] = { name = '[S]earch', _ = 'which_key_ignore' },
    ['<leader>w'] = { name = '[W]orkspace', _ = 'which_key_ignore' },
    ['<leader>t'] = { name = '[T]oggle', _ = 'which_key_ignore' },
    ['<leader>h'] = { name = 'Git [H]unk', _ = 'which_key_ignore' },
  }
  -- visual mode
  which_key.register({
    ['<leader>h'] = { name = 'Git [H]unk' },
  }, { mode = 'v'})
end

-- [[ Lazy ]]
local has_lazy,lazy = pcall(require, 'lazy')
if has_lazy then
  vim.keymap.set('n', '<leader>ls', lazy.home, { desc = '[L]azy [H]ome' })
  vim.keymap.set('n', '<leader>lk', lazy.check, { desc = '[L]azy Chec[k]' })
  vim.keymap.set('n', '<leader>lc', lazy.clean, { desc = '[L]azy [C]lean' })
  vim.keymap.set('n', '<leader>ls', lazy.sync, { desc = '[L]azy [S]ync' })
  vim.keymap.set('n', '<leader>lu', lazy.sync, { desc = '[L]azy [U]pdate' })
end

-- [[ telescope.nvim' ]]

-- Enable Telescope extensions if they are installed
local has_telescope,telescope = pcall(require, 'telescope')
-- local has_fzf,fzf = pcall(telescope.load_extension, 'fzf')
-- local has_ui_select,ui_select = pcall(telescope.load_extension, 'ui-select')

if has_telescope then
  -- See `:help telescope.builtin`
  local builtin = require 'telescope.builtin'
  vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
  vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
  vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
  vim.keymap.set('n', '<leader>st', builtin.git_files, { desc = '[S]earch [T]racked files' })
  vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
  vim.keymap.set('n', '<leader>sc', builtin.commands, { desc = '[S]earch [C]ommands Telescope' })
  vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
  vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
  vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
  vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
  vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
  vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })

  -- Slightly advanced example of overriding default behavior and theme
  vim.keymap.set('n', '<leader>/', function()
    -- You can pass additional configuration to Telescope to change the theme, layout, etc.
    builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown { previewer = false })
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
end

-- for i, v in pairs(package.loaded) do
--   print(i)
-- end

-- vim: ts=2 sts=2 sw=2 et
