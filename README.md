# dotfiles

My Mac config (Apple Silicon) in Nix: packages, macOS settings, GUI apps and dotfiles.

## How I use the Mac

- [AeroSpace](https://github.com/nikitabobko/AeroSpace) for tiling. `alt-hjkl` to focus, `alt-shift-hjkl` to move, `alt-<letter>` for workspaces.
- [JankyBorders](https://github.com/FelixKratz/JankyBorders) to see which window has focus.
- [Alacritty](https://github.com/alacritty/alacritty) for speed and minimalism, [tmux](https://github.com/tmux/tmux) for sessions.
- [Neovim](https://neovim.io) with [LazyVim](https://www.lazyvim.org).
- Elixir, Go, Rust, JS/TS on Bun. Sometimes Zig and C.
- CLI tools from Nix, GUI apps from Homebrew casks. Nothing installed by hand.

Want to use it? Fork, edit `user.nix`, run `install.sh`.

## What's inside

| What | Tool | File |
| --- | --- | --- |
| macOS settings, casks, fonts, services | [nix-darwin](https://github.com/nix-darwin/nix-darwin) | `darwin.nix` |
| CLI tools, languages, symlinks into `~` | [Home Manager](https://github.com/nix-community/home-manager) | `home.nix` |
| Pinned versions | Nix flake | `flake.nix`, `flake.lock` |
| Configs | plain files, symlinked | `config/`, `zsh/` |

- **Languages:** Elixir 1.20 / Erlang 28, Go, Rust (rustup), Zig, C (Apple clang, clangd), Python 3.14 + uv, Bun, Node 24.
- **Shell:** zsh, pure, atuin, fzf, zoxide, autosuggestions, syntax highlighting.
- **Apps:** AeroSpace, Chrome, Telegram, Claude Code. Homebrew casks.
- **Docker:** [Colima](https://github.com/abiosoft/colima).
- **Tunnels:** [cloudflared](https://github.com/cloudflare/cloudflared) to expose a local server over a public URL, e.g. for webhooks: `cloudflared tunnel --url localhost:3000`.
- **VPN:** `sstp start` (or just `sstp`, from `bin/sstp`) brings up the work SSTP tunnel and routes to the networks in `SSTP_ROUTES`; `sstp stop`, `sstp status`. macOS has no SSTP client, so it drives `sstpc` from Homebrew. Credentials go to `~/.zshrc.local`.
- **Work (`bin/hayot`):** `hayot vpn [start|stop|status]` wraps `sstp`; `hayot ssh` opens the bastion menu to pick a server (`Host hayot-bastion`); `hayot forward dev|prod` brings up the VPN if needed and opens a shell on the environment with its port forwards. Environments are `Host hayot-dev` / `Host hayot-prod` in `~/.ssh/config` (local, not in the repo); prod asks for confirmation.
- **Theme:** [black-metal](https://github.com/metalelf0/black-metal-theme-neovim) (bathory) in Neovim and Alacritty, transparent with blur.

Full lists: packages in `home.nix`, casks in `darwin.nix`.

## Install

```sh
git clone https://github.com/azabroflovski/dotfiles.git ~/dotfiles
$EDITOR ~/dotfiles/user.nix   # username, hostname, git name and email
~/dotfiles/install.sh
```

- Path must be exactly `~/dotfiles`, configs are symlinked there.
- Clone over HTTPS, a fresh Mac has no SSH key. First `git` call asks to install Xcode Command Line Tools.
- `install.sh` checks `user.nix` first and stops if it doesn't match the machine. Then: Nix, Homebrew, moves `/etc` files nix-darwin takes over, first build, Rust toolchain, `~/.zshrc.local`. Safe to re-run.

After that, restart the terminal and run once:

```sh
gh auth login        # choose SSH, it creates and uploads a key
git -C ~/dotfiles remote set-url origin git@github.com:azabroflovski/dotfiles.git
colima start
atuin import auto    # import old shell history
tldr --update
mkcert -install      # local CA for https://localhost
```

## Day to day

Configs in `config/` and `zsh/` are symlinks to the repo, edits apply right away. Rebuild only after changing `.nix` files.

| Task | How |
| --- | --- |
| Add a CLI tool | `home.packages` in `home.nix`, `rebuild` |
| Add a GUI app | `homebrew.casks` in `darwin.nix`, `rebuild`. Unlisted casks get uninstalled. |
| Add a config | `config/<name>/` + a line in `xdg.configFile` in `home.nix`, `rebuild` |
| Change a macOS setting | `system.defaults` in `darwin.nix`, `rebuild` |
| Update everything | `nup` |
| Roll back | `sudo darwin-rebuild --rollback` |

Old generations are garbage-collected after 14 days.

Packages: [search.nixos.org](https://search.nixos.org/packages?channel=unstable). Options: [nix-darwin](https://nix-darwin.github.io/nix-darwin/manual/), [Home Manager](https://nix-community.github.io/home-manager/options.xhtml).

## Aliases

Shell (`zsh/.zshrc`):

| Command | What it does |
| --- | --- |
| `rebuild` | `sudo darwin-rebuild switch --flake ~/dotfiles`, progress via `nom` |
| `nup` | Update flake inputs, `rebuild`, then upgrade Homebrew casks |
| `ngc` | Delete old generations and unused store paths. No rollback after this. |
| `try <pkg>` | Shell with a package from nixpkgs, nothing installed: `try cowsay` |
| `dots` | Neovim in `~/dotfiles` |
| `zshrc` | Open `zsh/.zshrc` |
| `nvimrc` | Neovim in the nvim config folder |
| `t [name]` | Attach to or create a tmux session, named after the current dir by default |
| `ports` | What's listening on which TCP port |
| `reload` | Restart zsh |
| `lt` | Tree, 2 levels, respects `.gitignore` |
| `mkcd <dir>` | `mkdir -p` + `cd` |
| `dc` | `docker compose` |
| `iexm` | `iex -S mix` |
| `claude-work` | Claude Code with a separate login and config in `~/.claude-work`. Work account; `claude` is personal. |
| `ls`, `ll`, `cat`, `vim` | `eza`, `eza -la`, `bat`, `nvim` |

Git (`config/git/config`):

| Command | What it does |
| --- | --- |
| `git st` | Short status, branch, ahead/behind |
| `git lg` | Last 20 commits as a graph |
| `git amend` | Add staged changes to the last commit, keep the message |
| `git undo` | Undo the last commit, keep changes staged |
| `git pushf` | `push --force-with-lease` |
| `git recent` | Branches by last commit date |
| `git gone` | Delete local branches whose remote is gone. Uses `-D`, unpushed commits on them are lost. |

Diffs go through [delta](https://github.com/dandavison/delta).

## Layout

```
dotfiles/
├── user.nix       # username, hostname, git name and email
├── flake.nix      # inputs, system named after the hostname
├── darwin.nix     # macOS defaults, casks, fonts, services
├── home.nix       # packages, symlinks, ~/.gitconfig
├── install.sh     # first-time setup
├── bin/           # own scripts, on PATH via .zshrc
├── zsh/           # → ~/.zshrc, ~/.zprofile
└── config/        # → ~/.config/{nvim,git,tmux,alacritty,aerospace,direnv}
```

## Gotchas

### `git add` new files before `rebuild`

Flakes are built from the git tree. An untracked `.nix` file, or a file it references, doesn't exist for Nix and `rebuild` fails with "path does not exist".

That's also why `user.nix` is committed: a gitignored `user.nix` + `user.example.nix` doesn't work with flakes.

### Secrets go to `~/.zshrc.local`

`~/.zshrc` is a symlink into this repo. `echo 'export TOKEN=...' >> ~/.zshrc`, as many guides suggest, puts the token in git.

`~/.zshrc.local` is outside the repo, mode 600, sourced by `.zshrc`. `install.sh` creates it.

### Rollback doesn't touch configs

Configs are symlinks to the repo, not store copies. `darwin-rebuild --rollback` restores packages and settings, not config contents. Use git for those.

### Removed macOS settings keep their value

Removing an option from `system.defaults` doesn't reset it. Set the default explicitly or change it in System Settings.

### Not everything is in Nix

- Rust toolchains: `~/.rustup`, update with `rustup update`.
- LSP servers: Mason (LazyVim) downloads them itself. Except `zls`, which must match the Zig version, and `nil`. Both come from Nix.
- `lldb`: from Xcode CLT. The nixpkgs one can't attach to processes without Apple's signed `debugserver`.

### Ctrl-R is atuin

atuin loads after fzf and takes `Ctrl-R`. fzf keeps `Ctrl-T` (files) and `Alt-C` (cd). `↑` is untouched.

## Per-project environments

Global languages are defaults. A project that needs other versions gets its own `flake.nix`:

```nix
{
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  outputs = { nixpkgs, ... }:
    let pkgs = nixpkgs.legacyPackages.aarch64-darwin;
    in {
      devShells.aarch64-darwin.default = pkgs.mkShell {
        packages = [ pkgs.beamPackages.elixir_1_18 pkgs.postgresql_17 ];
      };
    };
}
```

```sh
echo "use flake" > .envrc && direnv allow
```

direnv loads it on `cd` and unloads on leave, nix-direnv caches it. The nearest `.envrc` up the tree wins, so one at a monorepo root covers everything inside. Commit `flake.nix` and `flake.lock` with the project.
