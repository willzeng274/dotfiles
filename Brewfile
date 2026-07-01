tap "felixkratz/formulae"          # sketchybar, borders
tap "nikitabobko/tap"              # aerospace
tap "dopplerhq/doppler"            # doppler secrets CLI
tap "bufbuild/buf"
tap "skiptools/skip"
tap "stripe/stripe-cli"
tap "auth0/auth0-cli"
tap "ataraxy-labs/tap"
tap "hashicorp/tap"                 # terraform

brew "git"
brew "gh"                          # GitHub CLI (also used as git credential helper)
brew "git-delta"                   # pager for git/diff (configured in .gitconfig)
brew "git-lfs"                      # .gitconfig has lfs filters; run `git lfs install` after
brew "colordiff"
brew "neovim"                      # config: ~/.config/nvim (kickstart.nvim)
brew "bash"                        # modern bash (macOS ships 3.2)
brew "fish"                        # alt shell (zsh is primary)
brew "eza"                         # ls replacement (aliased in .zshrc)
brew "fd"                          # find replacement (drives fzf)
brew "fzf"                         # fuzzy finder
brew "ripgrep"
brew "zoxide"                      # smart cd
brew "tree"
brew "mdless"                      # markdown viewer
brew "jd"                          # JSON diff/patch

# TWM
brew "sketchybar"                  # config: ~/.config/sketchybar  (runs via LaunchAgent)
brew "borders"                     # config: ~/.config/borders     (runs via LaunchAgent)
# aerospace is a cask (below)

# languages/pkg managers
brew "fnm"                         # node version manager (primary, in .zshrc)
brew "go"
brew "rust"                        # also have rustup via ~/.cargo
brew "rbenv"                       # ruby
brew "swiftly"                     # swift toolchain manager
# NOTE: also installed outside brew: nvm, bun, deno, pnpm, mise, foundry
brew "cocoapods"
brew "maven"

# cloud/infra/k8s
brew "awscli"
brew "aws-iam-authenticator"
brew "kubernetes-cli"              # kubectl
brew "kubectx"
brew "helm"
brew "hashicorp/tap/terraform"     # was `terraform`; moved out of homebrew core
brew "doppler"                     # secrets
brew "stripe/stripe-cli/stripe"

brew "postgresql@18"
brew "redis"
brew "libpq"
brew "duckdb"

# rpc / protobuf / api
brew "protobuf"
brew "grpcurl"
brew "websocat"

# security / secrets / signing
brew "gnupg"                       # GPG (commit signing) — also migrate ~/.gnupg keys
brew "pinentry-mac"               # GPG pinentry
brew "pass"                        # password store — also migrate ~/.password-store
brew "oath-toolkit"               # `totp`/`2fa` shell functions
brew "mkcert"                      # local TLS certs
brew "sshpass"

# media / images / misc
brew "ffmpeg"
brew "poppler"                     # pdf utils
brew "pngcheck"
brew "pngpaste"                    # used by `qr` function
brew "zbar"                        # used by `qr` function (zbarimg)
brew "upx"
brew "mole"                        # mac cleanup
brew "llama.cpp"
brew "hf"                          # huggingface hub client

# apple / xcode dev
brew "xcbeautify"

# GUI apps
cask "kitty"                       # terminal (config: ~/.config/kitty)
# NOTE: using my own fork, aerospace.toml will NOT work with the latest stable version of aerospace
cask "nikitabobko/tap/aerospace"   # tiling WM (config: ~/.config/aerospace)
cask "keycastr"                    # keystroke visualiser (for recording)
cask "raycast"                     # launcher (config syncs via Raycast account)
cask "homerow"                     # keyboard nav
cask "shottr"                      # screenshots
cask "clop"                        # image/video compressor
cask "cursor"
cask "visual-studio-code"
cask "google-chrome"
cask "obs"                         # sam altman (those who know)
cask "obsidian"
cask "notion"
cask "figma"
cask "postman"                     # insomnia is better but eh
cask "slack"
cask "signal"
cask "telegram"
cask "spotify"
cask "discord@ptb"                 # Discord PTB
cask "claude"                      # Claude desktop
cask "chatgpt"
cask "nordlayer"
cask "cloudflare-warp"
cask "docker-desktop"              # token was renamed from `docker`
cask "codex"
cask "mitmproxy"
cask "skiptools/skip/skip"

# fonts (terminal + sketchybar need these)
cask "font-jetbrains-mono-nerd-font"   # kitty font_family
cask "font-hack-nerd-font"             # sketchybar
cask "font-fira-code-nerd-font"
cask "font-sketchybar-app-font"        # sketchybar app icons
cask "font-sf-pro"                     # sketchybar text (Apple SF Pro)
