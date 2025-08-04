-- orgmode.nvim plugin extensions

local M = {}

-- Archive headers to roam-daily
M.archive_to_daily = function()
  local roam = require 'org-roam'
  local notify = require 'snacks.notify'
  local org_api = require 'orgmode.api'

  if pcall(org_api.load, vim.fn.expand '%') == false then
    notify.error("Cannot archive heading:\nIt's not an org file!", { title = 'Orgmode' })
    do
      return
    end
  end

  local origin_org_file = org_api.load(vim.fn.expand '%')
  local origin_org_link = origin_org_file:get_link()
  local d_start, d_end = string.find(origin_org_link, '::')
  local origin_title = string.sub(origin_org_link, 1, d_start - 1)
  local origin_backlink = string.sub(origin_org_link, d_end + 2)

  -- Current heading manipulation before archive
  local headline = origin_org_file:get_closest_headline()

  if headline ~= nil then
    headline:set_tags { ' [[' .. origin_title .. '][' .. origin_backlink .. ']] ', 'ARCHIVE' }
  else
    notify.error("Cannot archive heading:\nIt's not a heading!", { title = 'Orgmode' })
    do
      return
    end
  end

  -- Can store some PROPERTIES
  -- headline:set_property('ARCHIVE_TIME', os.date '%Y-%m-%d %a %H:%M')

  local archive_date = nil
  if headline.closed ~= nil then
    local day = headline.closed.day
    if day < 10 then
      day = '0' .. day
    end

    local month = headline.closed.month
    if month < 10 then
      month = '0' .. month
    end

    archive_date = '' .. headline.closed.year .. '-' .. month .. '-' .. day
  else
    archive_date = os.date '%Y-%m-%d'
  end

  -- get target note file path
  local dailies_dir = roam.config.directory .. '/' .. roam.config.extensions.dailies.directory .. '/'
  local destination_path = dailies_dir .. archive_date .. '.org'

  -- ensure file exists
  if vim.fn.filereadable(destination_path) ~= 1 then
    -- Creat new empty daily note
    local target_file = io.open(destination_path, 'w')
    if target_file ~= nil then
      target_file:write ':PROPERTIES:\n'
      local uuid = require('orgmode.org.id').new()
      target_file:write(':ID: ' .. uuid .. '\n')
      target_file:write ':END:\n'
      target_file:write('#+TITLE: ' .. archive_date .. '\n\n')
      target_file:close()
    end
  end

  local destination = org_api.load(destination_path)
  org_api.refile {
    source = headline,
    destination = destination,
  }
end

-- Open quickfix list of links and backlinks for current node
M.qf_links_and_backlinks = function()
  local roam = require 'org-roam'

  roam.database:find_nodes_by_file(vim.fn.expand '%:p'):next(function(nodes)
    roam.ui.open_quickfix_list { id = nodes[1].id, backlinks = true, links = true, show_preview = true }
  end)
end

return M
