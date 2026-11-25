{
  lib,
  config,
  pkgs,
  namespace,
  ...
}:
let
  cfg = config.${namespace}.umbriel;
in
{
  options.${namespace}.umbriel = {
    enable = lib.mkEnableOption "Umbriel compositor user configuration";
  };

  # Umbriel replaces its built-in bind set as soon as a config defines
  # [keybinds], so this file lists every bind that should stay available.
  # Mandara's drop-in is included last-by-merge: [keybinds] entries merge by
  # key and the entries here win, which is why the terminal and launcher are
  # bound to what is actually installed here (wezterm, Mandara's launcher)
  # instead of the upstream defaults (kitty, Noctalia).
  config = lib.mkIf cfg.enable {
    # Folders open in COSMIC Files (also what Mod+E launches).
    xdg.mimeApps = {
      enable = true;
      defaultApplications."inode/directory" = "com.system76.CosmicFiles.desktop";
    };

    xdg.configFile."umbriel/config.toml".text = ''
      # Managed by Home Manager: modules/home/umbriel/default.nix
      # Live edits here are overwritten on the next switch.

      [general]
      # Started once per session by Umbriel itself, inside its own scope.
      autostart = [ "mandara" ]

      [include.optional]
      # Written by Mandara (rules, layer/window rules and its own binds).
      # Missing until Mandara first regenerates it; optional includes are fine.
      files = [ "~/.config/mandara/generated/umbriel.toml" ]

      [input.cursor]
      # Warp the pointer to a window when it gets focus, so picking a window
      # in Mandara's launcher also moves focus to its monitor.
      follows_focus = true

      [input.keyboard]
      numlock_toggle = true

      [appearance.blur]
      radius = 3

      [keybinds]
      # Applications and session
      "Mod+Return" = { action = "spawn ${lib.getExe pkgs.wezterm}", repeat = false }
      "Mod" = "spawn mandara msg launcher toggle"
      # File manager (COSMIC Files)
      "Mod+E" = { action = "spawn cosmic-files", repeat = false }
      "Mod+Q" = { action = "window-close", repeat = false }
      "Mod+Escape" = "session-quit"
      "Mod+Shift+Escape" = { action = "shortcuts-inhibit-toggle", allow_when_inhibited = true, repeat = false }

      # Media and brightness, routed through Mandara so its OSDs show.
      "XF86AudioRaiseVolume" = "spawn mandara msg audio volume up"
      "XF86AudioLowerVolume" = "spawn mandara msg audio volume down"
      "XF86AudioMute" = "spawn mandara msg audio mute-all toggle"
      "XF86AudioPlay" = "spawn mandara msg media play-pause"
      "XF86AudioNext" = "spawn mandara msg media next"
      "XF86AudioPrev" = "spawn mandara msg media previous"
      "XF86MonBrightnessUp" = "spawn mandara msg brightness up"
      "XF86MonBrightnessDown" = "spawn mandara msg brightness down"

      # Focus and movement
      "Mod+Left" = "window-focus-left"
      "Mod+Down" = "window-focus-down"
      "Mod+Up" = "window-focus-up"
      "Mod+Right" = "window-focus-right"
      "Mod+H" = "window-focus-left"
      "Mod+J" = "window-focus-down"
      "Mod+K" = "window-focus-up"
      "Mod+L" = "window-focus-right"
      "Mod+F1" = "window-focus-next"
      "Mod+Shift+Left" = "column-move-left"
      "Mod+Shift+Down" = "window-move-down"
      "Mod+Shift+Up" = "window-move-up"
      "Mod+Shift+Right" = "column-move-right"

      # Window state and layout
      "Mod+T" = { action = "window-toggle-floating", repeat = false }
      "Mod+Shift+T" = { action = "window-focus-switch-floating", repeat = false }
      "Mod+P" = { action = "window-toggle-pinned", repeat = false }
      "Mod+M" = { action = "window-toggle-maximize-to-edges", repeat = false }
      "Mod+F" = { action = "window-toggle-fullscreen", repeat = false }
      "Mod+Ctrl+F" = { action = "window-toggle-maximize", repeat = false }
      "Mod+R" = "window-cycle-primary-extent"
      "Mod+Shift+R" = "window-cycle-primary-extent-back"
      "Mod+Minus" = "window-modify-primary-extent -0.02"
      "Mod+Equal" = "window-modify-primary-extent +0.02"
      "Mod+Comma" = "window-consume-left"
      "Mod+Period" = "window-consume-right"
      "Mod+W" = { action = "column-toggle-tabbed", repeat = false }
      "Mod+Alt+Right" = "column-focus-tab-next"
      "Mod+Alt+Left" = "column-focus-tab-previous"
      "Mod+O" = { action = "overview-toggle", repeat = false }

      # Move the focused window to the monitor in that direction (COSMIC-style)
      "Mod+Alt+Shift+Left" = "window-move-to-output-left"
      "Mod+Alt+Shift+Right" = "window-move-to-output-right"
      "Mod+Alt+Shift+Up" = "window-move-to-output-up"
      "Mod+Alt+Shift+Down" = "window-move-to-output-down"

      # Focus the monitor in that direction
      "Mod+Ctrl+Left" = "output-focus-left"
      "Mod+Ctrl+Right" = "output-focus-right"
      "Mod+Ctrl+Up" = "output-focus-up"
      "Mod+Ctrl+Down" = "output-focus-down"

      # Workspaces
      "Mod+1" = "workspace-switch 1"
      "Mod+2" = "workspace-switch 2"
      "Mod+3" = "workspace-switch 3"
      "Mod+4" = "workspace-switch 4"
      "Mod+5" = "workspace-switch 5"
      "Mod+6" = "workspace-switch 6"
      "Mod+7" = "workspace-switch 7"
      "Mod+8" = "workspace-switch 8"
      "Mod+9" = "workspace-switch 9"
      "Mod+Shift+1" = "window-move-to-workspace 1"
      "Mod+Shift+2" = "window-move-to-workspace 2"
      "Mod+Shift+3" = "window-move-to-workspace 3"
      "Mod+Shift+4" = "window-move-to-workspace 4"
      "Mod+Shift+5" = "window-move-to-workspace 5"
      "Mod+Shift+6" = "window-move-to-workspace 6"
      "Mod+Shift+7" = "window-move-to-workspace 7"
      "Mod+Shift+8" = "window-move-to-workspace 8"
      "Mod+Shift+9" = "window-move-to-workspace 9"

      # Scratchpad
      "Mod+Shift+Space" = { action = "window-move-to-scratchpad", repeat = false }
      "Mod+Ctrl+Space" = { action = "window-restore-from-scratchpad", repeat = false }
      # Mandara's drop-in also binds Mod+Alt+Space to its launcher; this entry
      # wins on merge so the key toggles the scratchpad instead.
      "Mod+Alt+Space" = "scratchpad-toggle"
      "Mod+Tab" = "scratchpad-focus-next"

      [layout]
      extent_presets = [ 0.333, 0.5, 0.667 ]

      [layout.scrolling]
      default_extent_fraction = 0.5

      [hot_corners.top_left]
      enabled = true
      delay_ms = 500
      action = "overview-open"

      # Blur windows over the cached wallpaper blur.
      [[window_rule]]
      blur = true

      [[window_rule]]
      match.title = "^(Picture-in-Picture|Picture in picture)$"
      default_floating = true
      default_maximize = false
      default_position = { x = 20, y = 20, anchor = "bottom_right" }

      # Mandara draws its own surfaces; keep them unblurred and the lock
      # surface blurred, as its generated drop-in does for other compositors.
      [[layer_rule]]
      match.namespace = [ "^mandara-bar$", "^mandara-exclusion$", "^mandara-launcher$", "^mandara-switcher$", "^mandara-dock$", "^mandara-wallpaper$", "^mandara-osd$", "^mandara-notifications$", "^mandara-installer$", "^mandara-desktop$", "^mandara-desktop-menu$", "^mandara-desktop-edit$" ]
      blur = false

      [[layer_rule]]
      match.namespace = "^mandara-lock$"
      blur = true
    '';
  };
}
