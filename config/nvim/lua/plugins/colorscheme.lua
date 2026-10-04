return {
  {
    "metalelf0/black-metal-theme-neovim",
    lazy = false,
    priority = 1000,
    config = function()
      require("black-metal").setup({
        -- bathory | burzum | dark-funeral | darkthrone | emperor | gorgoroth | immortal | impaled-nazarene
        -- khold | marduk | mayhem | nile | taake | thyrfing | venom | windir
        theme = "bathory",
        -- Let the Alacritty background (opacity + blur) show through
        transparent = true,
        -- The default selection (#222222, same in every theme) is barely visible on a transparent bg
        highlights = {
          Visual = { bg = "#4a4a4a" },
        },
      })
    end,
  },
  {
    "LazyVim/LazyVim",
    opts = {
      -- `:colorscheme bathory` re-runs setup({}) and drops the options above, so load() instead
      colorscheme = function()
        require("black-metal").load()
      end,
    },
  },
}
