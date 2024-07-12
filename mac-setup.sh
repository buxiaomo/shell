#!/bin/bash
# Install Oy my zsh
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Install brew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

# Install Package
brew install --cask google-chrome
brew install --cask iterm2
brew install --cask notion

brew install --cask microsoft-teams microsoft-excel microsoft-outlook microsoft-powerpoint microsoft-word microsoft-auto-update

brew install --cask sourcetree pycharm goland visual-studio-code postman docker

brew install --cask qq wechat wechatwork telegram-desktop

brew install --cask bartender istat-menus tunnelblick balenaetcher parallels

brew install --cask qqmusic qqlive qiyimedia

brew install --cask thunder

brew install --cask virtualbox

# Install tools
brew install ansible yq jq wget telnet curl zsh terraform go python@3 node kubernetes-cli zoom pwgen

# Install Fonts
brew tap homebrew/cask-fonts
brew install --cask font-open-sans

# Install sshpass
brew tap esolitos/ipa
brew install esolitos/ipa/sshpass

git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
omz plugin enable zsh-autosuggestions

brew install sunnyyoung/repo/wechattweak-cli
