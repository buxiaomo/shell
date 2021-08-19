#!/bin/bash
# Install Oy my zsh
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Install brew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

# Install Package
brew install --cask google-chrome
brew install --cask zoomus
brew install --cask iterm2
brew install --cask docker
brew install --cask postman
brew install --cask notion
brew install --cask telegram-desktop
brew install --cask shiftit
brew install --cask visual-studio-code
brew install --cask sourcetree
brew install --cask cheatsheet
brew install --cask dash
brew install --cask microsoft-outlook
brew install --cask microsoft-powerpoint
brew install --cask microsoft-word
brew install --cask microsoft-auto-update
brew install --cask pycharm
brew install --cask goland
brew install --cask qq
brew install --cask wechat
brew install --cask wechatwork
brew install --cask qqmusic
brew install --cask qqlive
brew install --cask bartender
brew install --cask istat-menus
brew install --cask tunnelblick
brew install --cask balenaetcher
brew install --cask parallels

# Install tools
brew install wget telnet curl zsh terraform go python@3 node kubernetes-cli

# Install Fonts
brew tap homebrew/cask-fonts
brew cask install font-open-sans

# Install sshpass
brew tap esolitos/ipa
brew install esolitos/ipa/sshpass


git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions
source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
