return {
    "ravitemer/mcphub.nvim",
    dependencies = {
        "nvim-lua/plenary.nvim",
    },
    build = "npm install mcp-hub@4.2.1",  -- Pinned, no -g (Termux-safe). Bump deliberately.
    config = function()
        require("mcphub").setup()
    end
}
