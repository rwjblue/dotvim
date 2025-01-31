-- NOTE: this is largely copied and tweaked from
-- https://github.com/olimorris/codecompanion.nvim/blob/v11.17.1/lua/codecompanion/strategies/chat/slash_commands/fetch.lua

local adapters = require("codecompanion.adapters")
local client = require("codecompanion.http")
local config = require("codecompanion.config")

local log = require("codecompanion.utils.log")
local util = require("codecompanion.utils")

local fmt = string.format

---Format the output for the chat buffer
---@param url string
---@param text string
---@return string
local function format_output(url, text)
  return fmt(
    [[Here is the content from `%s` that I'm sharing with you:

<content>
%s
</content>]],
    url,
    text
  )
end

---Output the contents of the URL to the chat buffer
---@module "codecompanion.types"
---@param chat CodeCompanion.Chat
---@param data table
---@param opts table
---@return nil
local function output(chat, data, opts)
  local id = "<url>" .. data.url .. "</url>"

  chat:add_message({
    role = config.constants.USER_ROLE,
    content = format_output(data.url, data.content),
  }, { reference = id, visible = false })

  chat.references:add({
    source = "slash_command",
    name = "summarize",
    id = id,
  })

  if opts.silent then
    return
  end

  return util.notify(fmt("Added `%s` to the chat", data.url))
end

---Summarize the contents of a URL
---@module "codecompanion.types"
---@param chat CodeCompanion.Chat
---@param adapter table
---@param url string
---@param opts table
---@return nil
local function summarize(chat, adapter, url, opts)
  adapter.env = {
    query = function()
      return url
    end,
  }

  return client
      .new({
        adapter = adapter,
      })
      :request({
        url = url,
      }, {
        callback = function(err, data)
          if err then
            return log:error("Failed to summarize the URL, with error %s", err)
          end

          if data then
            local ok, body = pcall(vim.json.decode, data.body)
            if not ok then
              return log:error("Could not parse the JSON response")
            end
            if data.status == 200 then
              return output(chat, {
                content = body.data.output,
                url = url,
              }, opts)
            else
              return log:error("Error %s - %s", data.status, body.data.text)
            end
          end
        end,
      })
end

---@module "codecompanion.types"
---@class CodeCompanion.SlashCommand.SummarizeSlashCommand: CodeCompanion.SlashCommand
local SummarizeSlashCommand = {}

---@module "codecompanion.types"
---@param args CodeCompanion.SlashCommandArgs
function SummarizeSlashCommand.new(args)
  local self = setmetatable({
    Chat = args.Chat,
    config = args.config,
    context = args.context,
  }, { __index = SummarizeSlashCommand })

  return self
end

---Execute the slash command
---@param SlashCommands CodeCompanion.SlashCommands
---@param opts? table
---@return nil|string
function SummarizeSlashCommand:execute(SlashCommands, opts)
  vim.ui.input({ prompt = "Enter a URL" }, function(url)
    if url == "" or not url then
      return nil
    end

    return self:output(url, opts)
  end)
end

---Output the summary of the URL
---@param url string
---@param opts? table
---@return nil
function SummarizeSlashCommand:output(url, opts)
  local ok, adapter = pcall(loadfile, self.config.opts.provider)
  if not ok or not adapter then
    return log:error("Failed to load the adapter for the summarize Slash Command")
  end

  opts = opts or {}

  if type(adapter) == "function" then
    adapter = adapter()
  end

  adapter = adapters.resolve(adapter)
  if not adapter then
    return log:error("Failed to load the adapter for the summarize Slash Command")
  end

  return summarize(self.Chat, adapter, url, opts)
end

return SummarizeSlashCommand
