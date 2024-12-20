-- this is meant to be the userland config for the codecompanion extra
-- that is still in PR stage:
--    https://github.com/LazyVim/LazyVim/pull/4268
--
-- This will remain even after that PR lands
return {
  {
    "olimorris/codecompanion.nvim",
    optional = true,
    opts = function()
      -- Adapter configurations
      local adapters = {
        anthropic = function()
          return require("codecompanion.adapters").extend("anthropic", {
            env = { api_key = "AI_CLAUDE_API_KEY" },
          })
        end,

        openai = function()
          return require("codecompanion.adapters").extend("openai", {
            env = {
              api_key = "cmd:op item get 'OpenAI - nvim Token' --vault 'Rob (Work)' --fields label='credential' --reveal",
            },
          })
        end,

        copilot = {
          model = "claude-3.5-sonnet"
        },
      }

      -- Strategy configurations
      local strategies = {
        chat = { adapter = "anthropic" },
        inline = { adapter = "copilot" },
        agent = { adapter = "anthropic" },
      }

      -- Display configurations
      local display = {
        chat = {
          -- window = {
          --   layout = "float",
          --   border = "rounded",
          --   width = 0.6,
          --   height = 0.6,
          -- }
        }
      }

      return {
        adapters = adapters,
        strategies = strategies,
        display = display,
      }
    end,
  }
}
