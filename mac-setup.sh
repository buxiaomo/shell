#!/bin/bash
# Install Oy my zsh
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Install brew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

# Install Package
brew cask install google-chrome
brew cask install zoomus
brew cask install iterm2
brew cask install docker
brew cask install postman
brew cask install notion
brew cask install telegram-desktop
brew cask install shiftit
brew cask install visual-studio-code
brew cask install sourcetree
brew cask install cheatsheet
brew cask install dash
brew cask install microsoft-outlook
brew cask install microsoft-powerpoint
brew cask install microsoft-word
brew cask install microsoft-auto-update
brew cask install pycharm
brew cask install goland
brew cask install qq
brew cask install wechat
brew cask install wechatwork
brew cask install qqmusic
brew cask install qqlive
brew cask install bartender
brew cask install istat-menus
brew cask install tunnelblick
brew cask install balenaetcher
brew cask install parallels

# Install tools
brew install wget telnet curl zsh terraform go python@3 node kubernetes-cli

# Install Fonts
brew tap homebrew/cask-fonts
brew cask install font-open-sans

# Install sshpass
brew tap esolitos/ipa
brew install esolitos/ipa/sshpass