{
  programs.wezterm = {
    enable = true;
    extraConfig =
      /*
      lua
      */
      ''
        local wezterm = require("wezterm")

        -- Font configuration
        local font_name = "JetBrainsMono Nerd Font"
        local font_config = wezterm.font_with_fallback({
        	{ family = font_name, weight = "Regular" },
        })

        local config = wezterm.config_builder() or {}

        max_fps = 120

        -- General configuration
        config.font = font_config
        config.tab_bar_at_bottom = true
        config.check_for_updates = false
        config.hide_tab_bar_if_only_one_tab = true
        config.use_fancy_tab_bar = false
        --- config.tab_max_width = 4
        config.font_size = 18.5
        config.color_scheme = "Catppuccin Mocha"
        config.cursor_blink_rate = 500
        config.use_cap_height_to_scale_fallback_fonts = true
        config.default_cursor_style = "BlinkingUnderline"
        config.bold_brightens_ansi_colors = true
        config.front_end = "WebGpu"
        config.audible_bell = "Disabled"

        config.window_background_opacity = 0.8
        config.macos_window_background_blur = 100

        -- Window settings
        config.window_close_confirmation = "NeverPrompt"
        config.window_decorations = "RESIZE"
        -- config.window_padding = { left = 50, right = 50, top = 50, bottom = 50 }

        config.colors = {
        	tab_bar = {
        		background = "None",
        		active_tab = {
        			bg_color = "None",
        			fg_color = "#c0c0c0",
        			intensity = "Normal",
        			underline = "None",
        			italic = false,
        			strikethrough = false,
        		},

        		inactive_tab = {
        			bg_color = "None",
        			fg_color = "#808080",
        		},
        		inactive_tab_hover = {
        			bg_color = "None",
        			fg_color = "#909090",
        			italic = true,
        		},

        		new_tab = {
        			bg_color = "None",
        			fg_color = "#808080",
        		},
        		new_tab_hover = {
        			bg_color = "#494d64",
        			fg_color = "#909090",
        			italic = true,
        		},
        	},
        }

        wezterm.on("gui-startup", function(cmd)
        	local active_screen = wezterm.gui.screens()["active"]
        	local width = active_screen.width * 0.90
        	local height = active_screen.height * 0.85
        	local x = (active_screen.width - width) / 2 -- Center horizontally
        	local y = (active_screen.height - height) / 2 -- Center vertically

          if not cmd then
            print("Starting tmux")
            cmd = { args = { "/etc/profiles/per-user/vijay/bin/tmux", "-u", "new-session", "-A", "-s", "default_tmux" } }
          end
          local _, _, window = wezterm.mux.spawn_window(cmd)

        	window:gui_window():set_position(x, y)
        	window:gui_window():set_inner_size(width, height)
        end)

        wezterm.on("format-tab-title", function(tab)
        	local process_icons = {
        		["psql"] = "󱤢",
        		["usql"] = "󱤢",
        		["nvim"] = "",
        		["make"] = "󱂟",
        		["just"] = "󱂟",
        		["vim"] = " ",
        		["go"] = "",
        		["python3"] = "",
        		["zsh"] = " ",
        		["bash"] = " ",
        		["htop"] = "󱋊",
        		["cargo"] = "󱘗",
        		["sudo"] = "",
        		["git"] = "",
        		["lua"] = "󰢱",
        		["zola"] = "󰘯 ",
        		["zig"] = "",
        		["kubectl"] = "󱃾",
        		["ssh"] = "󰍹",
        		["tmux"] = "",
        	}

        	local process_name = string.gsub(tab.active_pane.foreground_process_name, "(.*[/\\])(.*)", "%2")
        	if string.find(process_name, "kubectl") then
        		process_name = "kubectl"
        	end

        	local function get_process()
        		if not tab.active_pane or tab.active_pane.foreground_process_name == "" then
        			return nil
        		end

        		return process_icons[process_name]
        	end

        	local process = get_process()
        	local title = process and string.format(" %s ", process) or "   "
        	return {
        		{ Text = title },
        	}
        end)

        local act = wezterm.action

        config.keys = {

        	-- copy paste
        	{ key = "c", mods = "ALT", action = act.CopyTo("Clipboard") },
        	{ key = "v", mods = "ALT", action = act.PasteFrom("Clipboard") },

        	-- goto last tab
        	{ key = "Tab", mods = "ALT", action = act.ActivateTabRelative(1) },

        	--- Copymode vi
        	{ key = "u", mods = "CMD", action = act.ActivateCopyMode },

        	--- Splits
        	{ key = "-", mods = "ALT", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
        	{ key = "\\", mods = "ALT", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },

        	--- spawn new tab
        	{ key = "t", mods = "ALT", action = act.SpawnTab("CurrentPaneDomain") },
        	{ key = "z", mods = "ALT", action = act.SpawnCommandInNewTab({ args = { "ssh", "zoro" } }) },
        	{ key = "u", mods = "ALT", action = act.SpawnCommandInNewTab({ args = { "ssh", "usopp" } }) },
        	{ key = "c", mods = "ALT", action = act.SpawnCommandInNewTab({ args = { "ssh", "chopper" } }) },
        	{ key = "n", mods = "ALT", action = act.SpawnCommandInNewTab({ args = { "ssh", "nami" } }) },

        	--- Pane switching
        	{ key = "h", mods = "SHIFT|CTRL", action = act.ActivatePaneDirection("Left") },
        	{ key = "l", mods = "SHIFT|CTRL", action = act.ActivatePaneDirection("Right") },
        	{ key = "k", mods = "SHIFT|CTRL", action = act.ActivatePaneDirection("Up") },
        	{ key = "j", mods = "SHIFT|CTRL", action = act.ActivatePaneDirection("Down") },
        	{ key = "z", mods = "SHIFT|CTRL", action = "TogglePaneZoomState" },

        	{ key = "h", mods = "SHIFT|ALT", action = wezterm.action({ AdjustPaneSize = { "Left", 5 } }) },
        	{ key = "j", mods = "SHIFT|ALT", action = wezterm.action({ AdjustPaneSize = { "Down", 5 } }) },
        	{ key = "k", mods = "SHIFT|ALT", action = wezterm.action({ AdjustPaneSize = { "Up", 5 } }) },
        	{ key = "l", mods = "SHIFT|ALT", action = wezterm.action({ AdjustPaneSize = { "Right", 5 } }) },
        }

        return config
      '';
  };
}
