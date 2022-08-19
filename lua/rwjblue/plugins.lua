local function check_or_install_packer()
  local install_path = vim.fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
  if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
    print('cloning packer.nvim')
    bootstrap = vim.fn.system({
      'git', 'clone', '--depth=1', 'https://github.com/wbthomason/packer.nvim', install_path
    })
    print(bootstrap)

    if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
      error('Failed to install packer to "' .. install_path .. '"')
    end

    vim.cmd [[packadd packer.nvim]]
  end
end

local function update(opts)
  opts = opts or { quit_on_install = false }

  check_or_install_packer()

  local packer = require 'packer'
  local util = require 'packer.util'

  -- autocmd User PackerComplete quitall
  vim.api.nvim_create_autocmd('User', {
    once = true,
    pattern = 'PackerComplete',
    callback = function()
      packer.snapshot(snapshot_path)

      if opts.quit_on_install then
        vim.cmd('quitall')
      end
    end
  })

  local snapshot_path = util.join_paths(vim.fn.stdpath('config'), 'plugins-dev.json')
  packer.startup({
    function(use)
      use 'wbthomason/packer.nvim'
      use 'neovim/nvim-lspconfig'
      use 'tpope/vim-sensible'
      use 'editorconfig/editorconfig-vim'
      use 'tpope/vim-fugitive'
      use 'tpope/vim-rhubarb' -- make fugitive understand github.com &co
      use 'tpope/vim-git'
      use 'tpope/vim-surround'
      use 'christoomey/vim-tmux-navigator'
      use 'airblade/vim-gitgutter'
      use 'wincent/terminus'
      use 'joshdick/onedark.vim'
      use 'kyazdani42/nvim-web-devicons'
      use 'kyazdani42/nvim-tree.lua'
      use {
        "folke/trouble.nvim",
        requires = "kyazdani42/nvim-web-devicons",
        config = function()
          require("trouble").setup {}
        end
      }

      use 'nvim-lua/popup.nvim'
      use 'nvim-lua/plenary.nvim'
      use {
        'nvim-telescope/telescope.nvim',
        requires = { 'popup.nvim', 'plenary.nvim' },
      }
      use { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make', requires = 'telescope.nvim' }

      use {
        'nvim-treesitter/nvim-treesitter',

        config = function()
          require'nvim-treesitter.configs'.setup {
            ensure_installed = 'all',

            highlight = {
              enable = true,

              -- currently `treesitter-markdown` doesn't support all syntax
              -- highlighting that we want (e.g. `**foo**` doesn't color that bolded
              -- text); this allows the older regexp based highlighting to work still
              additional_vim_regex_highlighting = { 'markdown' },
            },

            indent = {
              enable = true,
            },
          }
        end,

        run = function() require('nvim-treesitter.install').update({ with_sync = true }) end,
      }
    end,
    config = {
      snapshot = snapshot_path,
    }
  })

  packer.sync() -- Perform `PackerUpdate` and then `PackerCompile`
end

local function bootstrap()
  update { quit_on_install = true }
end

return {
  update = update,
  bootstrap = bootstrap,
}
