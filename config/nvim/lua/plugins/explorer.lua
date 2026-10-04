return {
  {
    "folke/snacks.nvim",
    opts = {
      picker = {
        sources = {
          -- Hide the filter input at the top of the file tree
          explorer = { layout = { hidden = { "input" } } },
        },
      },
    },
  },
}
