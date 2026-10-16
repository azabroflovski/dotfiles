{ config, pkgs, user, ... }:

let
  dotfiles = "${config.home.homeDirectory}/dotfiles";
  # Symlink straight to the file in the repo (not a /nix/store copy), so edits apply instantly
  link = path: config.lib.file.mkOutOfStoreSymlink "${dotfiles}/${path}";
in
{
  home.username = user.username;
  home.homeDirectory = "/Users/${user.username}";

  # Don't change, even when upgrading Home Manager.
  home.stateVersion = "26.05";

  home.packages = with pkgs; [
    # Languages
    nodejs_24
    pnpm
    bun
    python3
    uv
    lua5_4
    lua54Packages.luarocks
    go
    rustup
    zig
    # Same beamPackages set, so elixir is built against this erlang (plain `elixir` is still 1.18)
    beamPackages.erlang
    beamPackages.elixir_1_20

    # CLI
    git
    gh
    forgejo-cli # fj
    ripgrep
    fd
    fzf
    bat
    eza
    zoxide
    jq
    tree
    wget
    btop
    delta
    tealdeer
    just
    shellcheck
    xh
    yq-go
    dust
    duf
    hyperfine
    watchexec
    sd
    mkcert
    cloudflared
    ffmpeg
    imagemagick
    scc
    fastfetch
    postgresql # for psql; the server isn't started
    # Encrypted secrets (work repos). The age key is at ~/Library/Application Support/sops/age/keys.txt, not in this repo
    sops
    age

    # Network
    trippy # ping + traceroute TUI
    gping
    doggo # dig replacement
    bandwhich # per-process bandwidth, needs sudo
    iperf3
    nmap
    termshark # TUI for tshark (wireshark-cli)
    websocat
    croc # file transfer by code phrase

    # Fun
    aalib # aafire
    lavat
    cbonsai
    asciiquarium
    weathr
    astroterm
    cmatrix
    genact
    sl
    cowsay
    fortune-kind # fortune-mod needs recode, which is broken on darwin
    lolcat
    vitetris
    sssnake

    # C (lldb comes from Xcode Command Line Tools: nix's build can't attach without Apple's signed debugserver)
    clang-tools
    cmake
    bear

    # Nix
    nixfmt
    nil
    statix # linter, used by LazyVim's lang.nix extra
    nix-output-monitor
    nvd # package diff between generations, used by `rebuild`

    # Docker (colima is the VM; compose/buildx are linked as CLI plugins below)
    colima
    docker
    docker-compose
    docker-buildx

    # Shell
    pure-prompt
    direnv
    nix-direnv
    atuin
    zsh-autosuggestions
    zsh-syntax-highlighting
    tmux

    # GUI (the alacritty and mpv casks are disabled in Homebrew: they fail Gatekeeper)
    alacritty
    mpv
    yt-dlp # lets mpv play YouTube and other URLs

    # Editor
    neovim
    tree-sitter
  ];

  # Plain configs from the repo → symlinks in ~
  xdg.configFile = {
    "nvim".source = link "config/nvim";
    "aerospace".source = link "config/aerospace";
    "alacritty".source = link "config/alacritty";
    "direnv".source = link "config/direnv";
    "git".source = link "config/git";
    "tmux".source = link "config/tmux";
  };

  home.file = {
    ".zshrc".source = link "zsh/.zshrc";
    ".zprofile".source = link "zsh/.zprofile";

    # Identity from user.nix. Git reads both ~/.gitconfig and ~/.config/git/config
    ".gitconfig".text = ''
      [user]
      	name = ${user.git.name}
      	email = ${user.git.email}
    '';

    ".docker/cli-plugins/docker-compose".source =
      "${pkgs.docker-compose}/libexec/docker/cli-plugins/docker-compose";
    ".docker/cli-plugins/docker-buildx".source =
      "${pkgs.docker-buildx}/libexec/docker/cli-plugins/docker-buildx";
  };
}
