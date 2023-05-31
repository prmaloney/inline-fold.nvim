local namespace = vim.api.nvim_create_namespace("ts_node_action_conceal")
local tsnode = require('nvim-treesitter.ts_utils')
local M = {}

local marks = {}

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
    local mark_index
    for index, value in ipairs(marks) do
      if table.concat(value) == table.concat({ start_row, start_col, end_row, end_col }) then
        mark_index = index
      end
    end
    table.remove(marks, mark_index)
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
    table.insert(marks, { start_row, start_col, end_row, end_col })
  end
end

M.fold_node_at_cursor = function()
  M.fold_node(tsnode.get_node_at_cursor())
end

vim.api.nvim_create_autocmd('CursorMoved', {
  callback = function()
    local cursor_row, cursor_col = unpack(vim.api.nvim_win_get_cursor(0))
    for _, value in ipairs(marks) do
      local mark_start_row, mark_start_col, mark_end_row, mark_end_col = unpack(value)
      print(cursor_row, cursor_col, mark_start_row + 1, mark_start_col + 2)
      if cursor_row == mark_start_row + 1 and cursor_col == mark_start_col + 2 then
        vim.api.nvim_win_set_cursor(0, { mark_end_row + 1, mark_end_col + 1 })
      elseif cursor_row == mark_end_row + 1 and cursor_col == mark_end_col then
        vim.api.nvim_win_set_cursor(0, { mark_start_row + 1, mark_start_col + 1 })
      end
    end
  end
})

return M
