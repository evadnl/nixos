{ ... }:

{
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      palette = "catppuccin_mocha";
      format = "$directory$character";
      right_format = "$git_branch$git_status$aws$azure";

      time = {
        disabled = false;
        format = "[$time ]($style)";
        time_format = "%R";
        utc_time_offset = "local";
        style = "dimmed white";
      };

      character = {
        success_symbol = "[❯](Green)";
        error_symbol = "[❯](red)";
        vimcmd_symbol = "[❮](green)";
      };

      directory = {
        home_symbol = "~";
        truncation_length = 8;
        truncation_symbol = ".../";
        truncate_to_repo = true;
        read_only = " ";
        read_only_style = "red";
        format = "[ $path ]($style)";
      };

      os = {
        style = "(#a3aed2)";
        disabled = false;
      };

      aws = {
        symbol = "󰅟";
        format = "[$symbol ($profile )(\\($region\\) )(\\[$duration\\] )]($style)";
        style = "Peach bold";
      };

      azure = {
        format = "[$symbol ($subscription)]($style) ";
        symbol = "󰠅 ";
        style = "Blue bold";
      };

      docker_context = {
        symbol = "󰡨 ";
        only_with_files = true;
        format = "[ $symbol]($style)";
        style = "Blue bold";
        detect_files = [ "docker-compose.yml" "docker-compose.yaml" "Dockerfile" ];
      };

      git_branch = {
        symbol = " ";
        format = "[ $symbol $branch ]($style)";
        style = "";
      };

      git_status = {
        format = "[($all_status$ahead_behind )]($style)";
        conflicted = "=";
        ahead = "+";
        behind = "-";
        diverged = "⇕";
        up_to_date = "";
        untracked = "?";
        stashed = "\\$";
        modified = "!";
        renamed = "»";
        deleted = "✘";
        style = "";
      };

      python = {
        symbol = "P";
        pyenv_version_name = true;
      };

      palettes.catppuccin_mocha = {
        rosewater = "#f5e0dc";
        flamingo = "#f2cdcd";
        pink = "#f5c2e7";
        mauve = "#cba6f7";
        red = "#f38ba8";
        maroon = "#eba0ac";
        peach = "#fab387";
        yellow = "#f9e2af";
        green = "#a6e3a1";
        teal = "#94e2d5";
        sky = "#89dceb";
        sapphire = "#74c7ec";
        blue = "#89b4fa";
        lavender = "#b4befe";
        text = "#cdd6f4";
        subtext1 = "#bac2de";
        subtext0 = "#a6adc8";
        overlay2 = "#9399b2";
        overlay1 = "#7f849c";
        overlay0 = "#6c7086";
        surface2 = "#585b70";
        surface1 = "#45475a";
        surface0 = "#313244";
        base = "#1e1e2e";
        mantle = "#181825";
        crust = "#11111b";
      };
    };
  };
}
