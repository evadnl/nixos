{ pkgs, ... }:

{
  programs.zsh = {
    enable = true;

    history = {
      size = 100000;
      save = 100000;
      append = true;
      share = true;
      ignoreAllDups = true;
      ignoreSpace = true;
    };

    shellAliases = {
      ls = "ls --color";
      cat = "bat";
    };

    plugins = [
      {
        name = "zsh-abbr";
        src = pkgs.zsh-abbr;
        file = "share/zsh/zsh-abbr/zsh-abbr.zsh";
      }
    ];

    enableCompletion = true;

    completionInit = ''
      zstyle ':completion:*' menu select
      zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]-_}={[:upper:][:lower:]_-}' 'r:|=*' 'l:|=* r:|=*'
      zstyle ':completion:*' special-dirs true
      zstyle ':completion:*' list-colors "''${(s.:.)LS_COLORS}"
      zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'
    '';

  };

  # Managed abbreviations file — zsh-abbr loads this on startup
  home.file.".local/share/zsh/abbreviations".text = ''
    abbr "flushdns"="sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder"
    abbr "k"="kubectl"
    abbr "kdp"="kubectl describe"
    abbr "kex"="kubectl exec -it"
    abbr "kgn"="kubectl get nodes"
    abbr "kgp"="kubectl get pods"
    abbr "ksec"="kubectl get secrets"
    abbr "tf"="terraform"
    abbr "tfa"="terraform apply"
    abbr "tfp"="terraform plan"
    abbr "awsp"="export AWS_PROFILE=%"
  '';

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  # Catppuccin Mocha LS_COLORS for completion and ls coloring
  home.sessionVariables.LS_COLORS = builtins.concatStringsSep ":" [
    "rs=0"
    "di=38;2;137;180;250"      # blue       — directories
    "ln=38;2;137;220;235"      # sky        — symlinks
    "mh=00"                    #            — multi-hard-link
    "pi=38;2;250;179;135"      # peach      — named pipes
    "so=38;2;203;166;247"      # mauve      — sockets
    "do=38;2;203;166;247"      # mauve      — doors
    "bd=38;2;249;226;175;01"   # yellow     — block devices
    "cd=38;2;249;226;175;01"   # yellow     — char devices
    "or=38;2;243;139;168"      # red        — orphan symlinks
    "mi=38;2;243;139;168"      # red        — missing files
    "su=38;2;30;30;46;48;2;243;139;168"   # setuid
    "sg=38;2;30;30;46;48;2;250;179;135"   # setgid
    "tw=38;2;30;30;46;48;2;166;227;161"   # sticky+other-writable
    "ow=38;2;137;180;250;48;2;30;30;46"   # other-writable
    "st=38;2;30;30;46;48;2;137;180;250"   # sticky
    "ex=38;2;166;227;161"      # green      — executables
    # archives
    "*.tar=38;2;250;179;135" "*.tgz=38;2;250;179;135" "*.gz=38;2;250;179;135"
    "*.bz2=38;2;250;179;135" "*.xz=38;2;250;179;135" "*.zip=38;2;250;179;135"
    "*.7z=38;2;250;179;135"  "*.rar=38;2;250;179;135" "*.zst=38;2;250;179;135"
    # images
    "*.jpg=38;2;148;226;213" "*.jpeg=38;2;148;226;213" "*.png=38;2;148;226;213"
    "*.gif=38;2;148;226;213" "*.svg=38;2;148;226;213"  "*.webp=38;2;148;226;213"
    "*.bmp=38;2;148;226;213" "*.ico=38;2;148;226;213"
    # media
    "*.mp4=38;2;203;166;247" "*.mkv=38;2;203;166;247" "*.webm=38;2;203;166;247"
    "*.mp3=38;2;203;166;247" "*.flac=38;2;203;166;247" "*.ogg=38;2;203;166;247"
    "*.wav=38;2;203;166;247"
    # documents
    "*.pdf=38;2;245;224;220" "*.md=38;2;245;224;220"
    "*.epub=38;2;245;224;220" "*.doc=38;2;245;224;220" "*.docx=38;2;245;224;220"
    # code / config (lavender)
    "*.nix=38;2;180;190;254" "*.json=38;2;180;190;254" "*.yaml=38;2;180;190;254"
    "*.yml=38;2;180;190;254" "*.toml=38;2;180;190;254" "*.xml=38;2;180;190;254"
  ];

  home.packages = [ pkgs.bat ];
}
