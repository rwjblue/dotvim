local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

local function file_exists(path)
  return (vim.uv or vim.loop).fs_stat(path) ~= nil
end

if not file_exists(lazypath) then
  -- bootstrap lazy.nvim
  -- stylua: ignore
  vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable",
    lazypath })
end
vim.opt.rtp:prepend(vim.env.LAZY or lazypath)

local non_rdev = not file_exists("/etc/rdev.conf")

local rwjblue = require('rwjblue')

require("lazy").setup({
  spec = {
    -- add LazyVim and import its plugins
    { "LazyVim/LazyVim", import = "lazyvim.plugins" },
    -- import any extras modules here

    -- disable AI related features when using rdev
    rwjblue.maybe_add_plugin(non_rdev, { import = "lazyvim.plugins.extras.ai.copilot" }),

    -- import/override with your plugins
    { import = "plugins" },

    -- local_config.plugins is ilnked in from ~/src/workstuff/local-dotfiles/
    -- for machine local plugin overrides
    rwjblue.maybe_add_plugin(rwjblue.has_local_plugins, { import = "local_config.plugins" }),
  },
  defaults = {
    -- By default, only LazyVim plugins will be lazy-loaded. Your custom plugins will load during startup.
    -- If you know what you're doing, you can set this to `true` to have all your custom plugins lazy-loaded by default.
    lazy = false,
    -- It's recommended to leave version=false for now, since a lot the plugin that support versioning,
    -- have outdated releases, which may break your Neovim install.
    version = false, -- always use the latest git commit
    -- version = "*", -- try installing the latest stable version for plugins that support semver
  },

  -- By default lazy.nvim will write a lockfile to
  -- ~/.config/nvim/lazy-lock.json, but if we have `local_config.plugins` we
  -- want to write the lockfile to `~/.config/nvim/local_config/lazy-lock.json`
  -- instead (so we don't fight with the "public" vs "private" lockfile).
  lockfile = require('rwjblue').get_lockfile_path(),

  install = {
    missing = rwjblue.should_run_lazy_plugin_checks,
    colorscheme = { "tokyonight", "habamax" }
  },
  checker = {
    enabled = rwjblue.should_run_lazy_plugin_checks, -- automatically check for plugin updates
    frequency = 86400,                               -- check for updates once a day
  },
  performance = {
    rtp = {
      -- disable some rtp plugins
      disabled_plugins = {
        "gzip",
        -- "matchit",
        -- "matchparen",
        -- "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})
