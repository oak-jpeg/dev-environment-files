local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- ===== Font (ใช้ฟอนต์เดิมที่มีอยู่) =====
config.font = wezterm.font("JetBrainsMono NF")
config.font_size = 13.0
config.harfbuzz_features = { "calt=1", "clig=1", "liga=1" }

-- ===== Window =====
config.window_background_opacity = 1.0
config.window_decorations = "TITLE|RESIZE"
config.window_padding = {
	left = 8,
	right = 8,
	top = 8,
	bottom = 8,
}
config.macos_window_background_blur = 0
config.native_macos_fullscreen_mode = true

-- ===== Tab bar (คล้าย tmux status bar) =====
config.enable_tab_bar = false -- ปิดเพราะใช้ tmux แทน
config.window_close_confirmation = "NeverPrompt"

-- ===== Colors (One Dark theme) =====
config.colors = {
	foreground = "#e0e0e0",
	background = "#282c34",
	cursor_bg = "#e0e0e0",
	cursor_fg = "#282c34",
	cursor_border = "#e0e0e0",
	selection_fg = "#282c34",
	selection_bg = "#61afef",

	ansi = {
		"#282c34", -- black
		"#ff6b6b", -- red
		"#98c379", -- green
		"#e5c07b", -- yellow
		"#61afef", -- blue
		"#c678dd", -- magenta
		"#56b6c2", -- cyan
		"#e0e0e0", -- white
	},
	brights = {
		"#5c6370", -- bright black
		"#ff8787", -- bright red
		"#b5e890", -- bright green
		"#f0d590", -- bright yellow
		"#7cc5ff", -- bright blue
		"#d898e8", -- bright magenta
		"#73d0db", -- bright cyan
		"#ffffff", -- bright white
	},
}

-- ===== Shell: เปิด tmux อัตโนมัติ =====
config.default_prog = { "/bin/zsh", "-l", "-c", "tmux new-session -A -s main" }

-- ===== Performance =====
config.max_fps = 120
config.animation_fps = 1
config.cursor_blink_rate = 0 -- ปิด cursor กระพริบ

-- ===== Key bindings =====
config.keys = {
	-- Cmd+Enter = full screen
	{
		key = "Enter",
		mods = "CMD",
		action = wezterm.action.ToggleFullScreen,
	},
	-- Cmd+W = ปิด pane (ไม่ปิดทั้ง window)
	{
		key = "w",
		mods = "CMD",
		action = wezterm.action.CloseCurrentPane({ confirm = false }),
	},
}

return config
