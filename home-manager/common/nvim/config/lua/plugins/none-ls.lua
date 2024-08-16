return {
  "nvimtools/none-ls.nvim",
  config = function()
    local null_ls = require("null-ls")
    null_ls.setup({
      sources = {
        null_ls.builtins.formatting.stylua,
        null_ls.builtins.formatting.prettier,

        null_ls.builtins.formatting.alejandra,
        null_ls.builtins.code_actions.statix,
        null_ls.builtins.diagnostics.statix,

        null_ls.builtins.diagnostics.codespell,
        null_ls.builtins.completion.spell,
      },
    })
  end,
}
