local M = {}
local config = require('neo-img.config').get()

local echoraw = function(str)
  vim.fn.chansend(vim.v.stderr, str)
end

local get_extension = function(filename)
  return filename:match("^.+%.(.+)$")
end

local display_image = function(filepath)
  local command
  if config.backend == "kitty" then
    command = 'kitty +kitten icat "'
  elseif config.backend == "chafa" then
    command = 'chafa --align=center -s 60 --format=sixels "'
  else
    command = 'viu "'
  end
  command = command .. filepath .. '"'

  if vim.fn.filereadable(filepath) == 0 then
    vim.notify("File not found: " .. filepath, vim.log.levels.ERROR)
    return
  end

  echoraw(vim.fn.system(command))
  -- vim.fn.termopen(command .. filepath .. '"')
end

function M.setup_autocommands()
  local group = vim.api.nvim_create_augroup('NeoImg', { clear = true })

  if config.auto_open then
    vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
      group = group,
      pattern = "*",
      callback = function()
        local filepath = vim.fn.expand('%:p')
        local ext = get_extension(filepath)

        if ext and config.supported_extensions[ext:lower()] then
          display_image(filepath)
        end
      end
    })

    -- adding oil.nvim preview support.
    -- maybe won't work if the user creates a new win manually, hence adding option to diable it
    if config.oil_preview then
      vim.api.nvim_create_autocmd("BufEnter", {
        pattern = "oil://*",
        callback = function()
          local wins = vim.api.nvim_list_wins()
          local active_win = vim.api.nvim_get_current_win()

          if #wins > 1 then
            for _, win in ipairs(wins) do
              if win ~= active_win then
                local oil = require("oil")
                local entry = oil.get_cursor_entry()
                local dir = oil.get_current_dir()
                if entry ~= nil then
                  local filepath = dir .. entry.parsed_name
                  local ext = get_extension(filepath)

                  if ext and config.supported_extensions[ext:lower()] then
                    local buf_id = vim.api.nvim_win_get_buf(win)
                    vim.api.nvim_win_call(win, function()
                      vim.api.nvim_buf_set_option(buf_id, 'modified', false)
                      display_image(filepath)
                    end)
                  end
                end
                break
              end
            end
          end
        end,
      })
    end
  end

  -- Add command to manually trigger image display
  vim.api.nvim_create_user_command('NeoImgShow', function()
    local filepath = vim.fn.expand('%:p')
    M.display_image(filepath)
  end, {})
end

return M
