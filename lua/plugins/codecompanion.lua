local prompt_library = require('rwjblue.codecompanion.prompts')

return {
  {
    "olimorris/codecompanion.nvim",
    cmd = { "CodeCompanion", "CodeCompanionActions", "CodeCompanionChat", "CodeCompanionCmd" },

    keys = {
      { "<leader>a",  "",                                  desc = "+ai",        mode = { "n", "v" } },
      { "<leader>aa", "<cmd>CodeCompanionActions<cr>",     mode = { "n", "v" }, desc = "Prompt Actions (CodeCompanion)" },
      { "<leader>af", "<cmd>CodeCompanionChat Toggle<cr>", mode = { "n", "v" }, desc = "Toggle (CodeCompanion)" },
      { "<leader>ac", "<cmd>CodeCompanionChat Add<cr>",    mode = "v",          desc = "Add code to CodeCompanion" },
    },

    opts = {
      -- Adapter configurations
      adapters = {
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
      },

      -- Strategy configurations
      strategies = {
        chat = {
          adapter = "anthropic",

          slash_commands = {
            ["summarize"] = {
              callback = "rwjblue.codecompanion.slash_commands.summarize",
              description = "Summarize the URL contents",
              opts = {
                adapter = "rwjblue.codecompanion.adapters.kagi"
              }
            }
          },
        },
        inline = { adapter = "anthropic" },
        agent = { adapter = "anthropic" },
      },

      -- Display configurations
      display = {
        chat = {
          -- window = {
          --   layout = "float",
          --   border = "rounded",
          --   width = 0.6,
          --   height = 0.6,
          -- }
        }
      },

      prompt_library = prompt_library,
    }
  },

  {
    "saghen/blink.cmp",
    optional = true,
    opts = {
      sources = {
        per_filetype = {
          codecompanion = { "codecompanion" },
        }
      },
    }
  },

  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      local LualineCodeCompanionSpinner = require("lualine.component"):extend()
      local spinner_symbols = {
        "⠋",
        "⠙",
        "⠹",
        "⠸",
        "⠼",
        "⠴",
        "⠦",
        "⠧",
        "⠇",
        "⠏",
      }

      function LualineCodeCompanionSpinner:init(options)
        LualineCodeCompanionSpinner.super.init(self, options)
        self.spinner_index = 1

        local group = vim.api.nvim_create_augroup("CodeCompanionHooks", {})

        vim.api.nvim_create_autocmd({ "User" }, {
          pattern = "CodeCompanionRequest*",
          group = group,
          callback = function(request)
            if request.match == "CodeCompanionRequestStarted" then
              self.processing = true
            elseif request.match == "CodeCompanionRequestFinished" then
              self.processing = false
            end
          end,
        })
      end

      -- Function that runs every time statusline is updated
      function LualineCodeCompanionSpinner:update_status()
        if self.processing then
          self.spinner_index = (self.spinner_index % #spinner_symbols) + 1
          return [[󰚩 ]] .. spinner_symbols[self.spinner_index]
        else
          return nil
        end
      end

      opts.sections = opts.sections or {}
      opts.sections.lualine_y = vim.list_extend(
        opts.sections.lualine_y or {},
        {
          { LualineCodeCompanionSpinner },
        }
      )

      return opts
    end,
  },
}
