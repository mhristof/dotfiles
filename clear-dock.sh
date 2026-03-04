#!/usr/bin/env bash
# Clear all icons from the Dock

defaults write com.apple.dock persistent-apps -array
defaults write com.apple.dock persistent-others -array
defaults write com.apple.dock recent-apps -array
killall Dock

echo "Dock cleared"
