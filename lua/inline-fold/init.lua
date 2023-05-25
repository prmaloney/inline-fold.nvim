local namespace = vim.api.nvim_create_namespace("ts_node_action_conceal")
local tsnode = require('nvim-treesitter.ts_utils')
local M = {}

M.fold_node = function(node)
  if node == nil then return end
  vim.api.nvim_win_set_option(0, "concealcursor", "nc")
  vim.api.nvim_win_set_option(0, "conceallevel", 2)


  local start_row, start_col, end_row, end_col = node:range()

  local extmark_id = unpack(
    vim.api.nvim_buf_get_extmarks(
      0, namespace, { start_row, start_col }, { end_row, end_col }, {}
    )[1] or {}
  )

  if extmark_id then
    vim.api.nvim_buf_del_extmark(0, namespace, extmark_id)
  else
    vim.api.nvim_buf_set_extmark(
      0,
      namespace,
      start_row,
      start_col,
      {
        end_row = end_row,
        end_col = end_col,
        conceal = '󰇘',
      }
    )
  end
end

M.fold_node_at_cursor = function()
  M.fold_node(tsnode.get_node_at_cursor())
end

M.Fold_attributes_for_node = function(node)
  if node == nil then return end

  if node:child_count() == 0 and node:type() == 'attribute_value' then
    M.Fold_node(node)
  end

  for child, _ in node:iter_children() do
    M.Fold_attributes_for_node(child)
  end
end

function M.CollapseAll()
  local lang_tree = require('nvim-treesitter.parsers').get_parser(0)
  if lang_tree == nil then return end

  for _, tree in ipairs(lang_tree:trees()) do
    local root = tree:root()
    M.Fold_attributes_for_node(root)
  end
end

return M
