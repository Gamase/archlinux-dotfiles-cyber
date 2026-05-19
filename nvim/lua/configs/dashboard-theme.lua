-- Colores dashboard
vim.api.nvim_set_hl(0, "DashboardHeader", { fg = "#3399ff", bold = true })
vim.api.nvim_set_hl(0, "DashboardCenter", { fg = "#66bbff", bold = true })
vim.api.nvim_set_hl(0, "DashboardFooter", { fg = "#0055ff", italic = true })
vim.api.nvim_set_hl(0, "DashboardKey", { fg = "#3399ff", bold = true })
vim.api.nvim_set_hl(0, "DashboardDesc", { fg = "#66bbff", bold = true })
vim.api.nvim_set_hl(0, "DashboardIcon", { fg = "#3399ff", bg = "NONE", nocombine = true })
-- Transparencia
vim.api.nvim_set_hl(0, "Normal", { bg = "NONE" })
vim.api.nvim_set_hl(0, "NormalFloat", { bg = "NONE" })
vim.api.nvim_set_hl(0, "SignColumn", { bg = "NONE" })
vim.api.nvim_set_hl(0, "NormalNC", { bg = "NONE" })
vim.api.nvim_set_hl(0, "EndOfBuffer", { bg = "NONE" })
vim.api.nvim_set_hl(0, "ColorColumn", { bg = "NONE" })
vim.api.nvim_set_hl(0, "CursorColumn", { bg = "NONE" })
-- Quitar rayas verticales en el dashboard
vim.api.nvim_create_autocmd("FileType", {
  pattern = "dashboard",
  callback = function()
    vim.opt_local.colorcolumn = ""
    vim.opt_local.cursorcolumn = false
    vim.opt_local.cursorline = false
    vim.b.indent_blankline_enabled = false
    pcall(function()
      require("ibl").setup_buffer(0, { enabled = false })
    end)
  end,
})
