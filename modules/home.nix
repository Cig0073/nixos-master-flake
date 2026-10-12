{ pkgs, ... }:
{
  home.packages = with pkgs; [
    jellyfin-tui
    yazi
    fastfetch
    tldr
    ytm-player
    nil           # Nix LSP
    nixpkgs-fmt   # Nix formatter
    kdePackages.okular
    mpv
    ueberzugpp
  ];

  # ── Cursor ────────────────────────────────────────────────────────────────
  home.pointerCursor = {
    enable  = true;
    package = pkgs.bibata-cursors;
    name    = "Bibata-Modern-Ice";
    size    = 24;
    gtk.enable = true;  # GTK apps respect the cursor
    x11.enable = true;  # XWayland (Steam) respects the cursor
  };

  home.sessionVariables = {
    XCURSOR_THEME = "Bibata-Modern-Ice";
    XCURSOR_SIZE  = "24";
  };

  # ── Browser: qutebrowser ─────────────────────────────────────────────────
  programs.qutebrowser = {
    enable = true;
    settings = {
      tabs.show                              = "multiple";
      fonts.default_family                   = "JetBrains Mono";
      fonts.default_size                     = "10pt";
      fonts.web.family.fixed                 = "JetBrains Mono";
      statusbar.show                         = "in-mode";
      scrolling.smooth                       = true;
      colors.webpage.preferred_color_scheme  = "dark";
      colors.webpage.darkmode.enabled        = true;
      colors.webpage.darkmode.algorithm      = "lightness-cielab";
      colors.webpage.darkmode.policy.images  = "never";
    };
  };

  programs.firefox = {
    enable = true;
    configPath = ".mozilla/firefox";
  };

  # ── Editor: Helix ─────────────────────────────────────────────────────────
  programs.helix = {
    enable        = true;
    defaultEditor = true;

    settings = {
      theme = "tokyonight";
      editor = {
        line-number  = "relative";
        mouse        = true;
        cursorline   = true;
        color-modes  = true;
        cursor-shape = {
          insert = "bar";
          normal = "block";
          select = "underline";
        };
        indent-guides = {
          render    = true;
          character = "⎸";
        };
      };
    };

    # Override tokyonight to be fully transparent (inherits Niri/Kitty blur)
    themes.tokyonight = {
      inherits           = "tokyonight";
      "ui.background"         = { fg = "none"; bg = "none"; };
      "ui.virtual.whitespace" = { fg = "none"; bg = "none"; };
    };
  };

  # ── Terminal: Kitty ───────────────────────────────────────────────────────
  programs.kitty = {
    enable = true;
    settings = {
      # Transparency
      background_opacity        = "0.85";
      dynamic_background_opacity = "yes";

      # Layout
      window_padding_width = 14;
      placement_strategy   = "center";

      # No title bars — let Niri handle window chrome
      hide_window_decorations = "yes";
      confirm_os_window_close = 0;

      # Audio
      enable_audio_bell    = "no";
      visual_bell_duration = "0.0";

      # Cursor
      cursor_shape           = "beam";
      cursor_beam_thickness  = "2.0";
      cursor_blink_interval  = "0.3 ease-in-out";
      cursor_trail           = 5;
      cursor_trail_decay     = "0.05 0.20";
      cursor_trail_start_threshold = 1;

      # Mouse / URLs
      detect_urls            = "yes";
      url_style              = "curly";
      underline_hyperlinks   = "hover";
      show_hyperlink_targets = "yes";
      copy_on_select         = "clipboard";
      mouse_hide_wait        = "2.0";

      # Performance (~200Hz potential)
      repaint_delay          = 5;
      input_delay            = 1;
      sync_to_monitor        = "yes";
      scrollback_lines       = 20000;
      wheel_scroll_multiplier = "5.0";
      shell_integration      = "enabled";

      # Tab bar
      tab_bar_edge        = "top";
      tab_bar_style       = "powerline";
      tab_powerline_style = "slanted";
      tab_bar_min_tabs    = 1;
      active_tab_font_style   = "bold";
      inactive_tab_font_style = "italic";
    };

    extraConfig = ''
      include dank-theme.conf
      include dank-tabs.conf
    '';
  };

  # ── Wallpaper engine ──────────────────────────────────────────────────────
  services.linux-wallpaperengine.enable = true;

  home.stateVersion = "25.05";
}
