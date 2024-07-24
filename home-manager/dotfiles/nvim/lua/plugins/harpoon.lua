return {
	"ThePrimeagen/harpoon",
	lazy = true,
	dependencies = { "nvim-lua/plenary.nvim" },
	keys = {
		{
			"A",
			function()
				require("harpoon.mark").add_file()
			end,
		},
		{
			"H",
			function()
				require("harpoon.ui").toggle_quick_menu()
			end,
		},
		{
			"!",
			function()
				require("harpoon.ui").nav_file(1)
			end,
		},
		{
			"@",
			function()
				require("harpoon.ui").nav_file(2)
			end,
		},
		{
			"#",
			function()
				require("harpoon.ui").nav_file(3)
			end,
		},
		{
			"$",
			function()
				require("harpoon.ui").nav_file(4)
			end,
		},
		{
			"%",
			function()
				require("harpoon.ui").nav_file(5)
			end,
		},
	},
	config = function()
		require("harpoon").setup()
	end,
}
