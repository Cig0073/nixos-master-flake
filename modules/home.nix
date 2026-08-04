{ pkgs, ...}:

{

  home.packages = with pkgs; [
    #tree
    qutebrowser
    jellyfin-tui
    yazi
    fastfetch
    tldr
    ytm-player
    nil
    nixpkgs-fmt
    kdePackages.okular
    moonlight-qt
    mpv
  ];

  programs.firefox.enable = true;
  
  programs.helix = {
    enable = true;
    defaultEditor = true;
  
    # ── Editor Configuration ────────────────────────────────────────
    settings = {
      theme = "tokyonight"; # High-contrast aesthetic that pairs with Matugen

      editor = {
        line-number = "relative"; # Fast navigation jumping
        mouse = true;             # Mouse support works flawlessly out of the box
        cursorline = true;        # Highlight the current row
        color-modes = true;       # Changes cursor color based on Normal/Insert mode
          
        cursor-shape = {
          insert = "bar";
          normal = "block";
          select = "underline";
        };
  
        indent-guides = {
          render = true;
          character = "⎸";
        };
      };
    };
  
    # ── Forcing Complete Transparency ──────────────────────────────
    # Helix allows theme overrides. This completely strips the background color
    # properties so Helix is 100% transparent, inheriting your Niri/Kitty blur.
    themes = {
      tokyonight = {
        inherits = "tokyonight";
        "ui.background" = { fg = "none"; bg = "none"; };
        "ui.virtual.whitespace" = { fg = "none"; bg = "none"; };
      };
    };
  };

  programs.kitty = {
    enable = true;
    settings = {
        # Transparency (Matugen will color the background, this keeps it see-through)
        background_opacity = "0.85";
        dynamic_background_opacity = "yes";
        
        # Aggressive Spatial Padding
        window_padding_width = 14;
        placement_strategy = "center";
        
        # Fully nuke title bars and system borders (Let Niri handle geometry)
        hide_window_decorations = "yes";
        confirm_os_window_close = 0;
        enable_audio_bell = "no";
        visual_bell_duration = "0.0";
    
        # ── Advanced Cursor Telemetry ───────────────────────────────────
        cursor_shape = "beam";
        cursor_beam_thickness = "2.0";
        cursor_blink_interval = "0.3 ease-in-out";
        
        # Ghost particle trail physics
        cursor_trail = 5;                  # Higher count for a longer, sleeker tail
        cursor_trail_decay = "0.05 0.20";  # Faster snap-to-decay physics
        cursor_trail_start_threshold = 1;  # Triggers on almost any movement
    
        # ── Interactive Hyperlink & Mouse Spice ─────────────────────────
        detect_urls = "yes";
        url_style = "curly";               # Edgy, wavy underlines for paths/links
        underline_hyperlinks = "hover";
        show_hyperlink_targets = "yes";    # Displays terminal destination on hover
        copy_on_select = "clipboard";      # Instant copy to system clipboard upon highlight
        mouse_hide_wait = "2.0";           # Vaporizes the mouse cursor quickly when typing
    
        # ── High-Performance Engine Tuning ──────────────────────────────
        # Low-latency configuration optimized for high refresh rates
        repaint_delay = 5;                 # Sub-8ms render cycles (~200Hz potential)
        input_delay = 1;                   # Direct line keyboard interrupt polling
        sync_to_monitor = "yes";
        scrollback_lines = 20000;          # Massive buffer for deep command logs
        wheel_scroll_multiplier = "5.0";   # Fast, aggressive scrolling momentum
        shell_integration = "enabled";     # Deep shell tracking for prompt jumping
    
        # ── Persistent Structural Tab Bar ───────────────────────────────
        tab_bar_edge = "top";
        tab_bar_style = "powerline";
        tab_powerline_style = "slanted";
        tab_bar_min_tabs = 1;              # ALWAYS show the tab bar even with 1 tab
        active_tab_font_style = "bold";
        inactive_tab_font_style = "italic";
      };
      extraConfig = ''
        include dank-theme.conf
        include dank-tabs.conf
      '';
    };

	# This value determines the Home Manager release that your
	# configuration is compatible with. This helps avoid breakage
	# when a new Home Manager release introduces backwards
	# incompatible changes.
	#
	# You can update Home Manager without changing this value. See
	# the Home Manager release notes for a list of state version
	# changes in each release.
	home.stateVersion = "25.05";
}
