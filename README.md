# Kickstart.nvim

It's a first step to configure the nvim editor

## Installation

First you need to install nvim if it is not installed

```bash
  curl -LO https://github.com/neovim/neovim/releases/download/stable/nvim-linux-x86_64.tar.gz
  sudo rm -rf /opt/nvim-linux-x86_64
  sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz
  sudo rm /usr/bin/nvim
  sudo ln -s /opt/nvim-linux-x86_64/bin/nvim /usr/bin/nvim
  rm nvim-linux-x86_64.tar.gz
```

Clone the project

```bash
  git clone https://github.com/beemensameh/kickstart.nvim ~/.config/nvim
```

Start nvim

```bash
  nvim
```

