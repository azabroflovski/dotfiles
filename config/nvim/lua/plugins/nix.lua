return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- nil comes from home.nix; don't let Mason build its own copy
        nil_ls = { mason = false },
      },
    },
  },
}
