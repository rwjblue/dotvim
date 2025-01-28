--- Interacting with https://help.kagi.com/kagi/api/summarizer.html
---
---@module "codecompanion.types"
---@class CodeCompanion.AdapterArgs
return {
  name = "kagi",
  opts = {
    stream = false,
  },
  url = "https://kagi.com/api/v0/summarize",
  headers = {
    ["Content-Type"] = "application/json",
    ["Accept"] = "application/json",
    ["Authorization"] = "Bot " .. vim.env.AI_KAGI_API_KEY,
  },
  handlers = {
    set_body = function(self, data)
      local body = {}

      -- Handle required parameters (url XOR text)
      if data.url then
        body.url = data.url
      elseif data.text then
        body.text = data.text
      end

      -- Handle optional parameters
      if data.engine then
        body.engine = data.engine
      else
        -- default to agnes (Formal, technical, analytical summary)
        body.engine = "agnes"
      end

      -- defaults to 'summary'
      if data.summary_type then
        body.summary_type = data.summary_type
      end

      if data.target_language then
        body.target_language = data.target_language
      end

      -- defaults to allowing cached responses
      if data.cache ~= nil then
        body.cache = data.cache
      end

      return body
    end,
  },
}
