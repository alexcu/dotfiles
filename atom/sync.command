#!/usr/bin/env bash
echo "Removing existing .atom config..."
rm -rf ~/.atom
echo "Linking ~/Dropbox/Apps/Atom -> ~/.atom"
ln -nsf ~/Dropbox/Apps/Atom/ ~/.atom
