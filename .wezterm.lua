-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

config.font = wezterm.font({
	family = "JetBrains Mono",
	harfbuzz_features = { "calt=0", "clig=0", "liga=0" },
})

config.font_size = 11.0
config.use_fancy_tab_bar = false

config.background = {
	{
		source = {
			File = os.getenv("HOME") .. "/Downloads/monterey.png",
		},
		width = "100%",
		repeat_x = "Mirror", -- Adjust to mirror horizontally
		repeat_y = "NoRepeat", -- No vertical tiling

		hsb = { brightness = 0.1 },

		attachment = { Parallax = 0.1 },
	},
}

return config
