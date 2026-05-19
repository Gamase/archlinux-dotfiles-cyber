require("configs.dashboard-theme")

return {
  {
    "stevearc/conform.nvim",
    -- event = 'BufWritePre', -- uncomment for format on save
    opts = require "configs.conform",
  },

  -- These are some examples, uncomment them if you want to see them work!
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },

	{
  "nvimdev/dashboard-nvim",
  event = "VimEnter",
  config = function()
    require("dashboard").setup({
      theme = "doom",
      config = {
        header = {
          "",
          "██╗  ██╗ ██████╗ ███╗   ███╗███████╗██████╗  █████╗ ███████╗███████╗",
          "██║  ██║██╔═══██╗████╗ ████║██╔════╝██╔══██╗██╔══██╗██╔════╝██╔════╝",
          "███████║██║   ██║██╔████╔██║█████╗  ██████╔╝███████║███████╗█████╗  ",
          "██╔══██║██║   ██║██║╚██╔╝██║██╔══╝  ██╔══██╗██╔══██║╚════██║██╔══╝  ",
          "██║  ██║╚██████╔╝██║ ╚═╝ ██║███████╗██████╔╝██║  ██║███████║███████╗",
          "╚═╝  ╚═╝ ╚═════╝ ╚═╝     ╚═╝╚══════╝╚═════╝ ╚═╝  ╚═╝╚══════╝╚══════╝",
          "",
        },
        center = {
          {
            icon = "  ",
            desc = "New File",
            key = "n",
            action = "enew",
          },
          {
            icon = "  ",
            desc = "Find File",
            key = "f",
            action = "Telescope find_files",
          },
          {
            icon = "󰊄  ",
            desc = "Find Text",
            key = "t",
            action = "Telescope live_grep",
          },
          {
            icon = "  ",
            desc = "Recent Files",
            key = "r",
            action = "Telescope oldfiles",
          },
          {
            icon = "  ",
            desc = "Config",
            key = "c",
            action = "edit ~/.config/nvim/lua/plugins/init.lua",
          },
          {
            icon = "  ",
            desc = "Quit",
            key = "q",
            action = "qa",
          },
        },
        footer = { "", "  github.com/cyber" },
      },
    })
  end,
  dependencies = { "nvim-tree/nvim-web-devicons" },
},
}

