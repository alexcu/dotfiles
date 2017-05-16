#!/usr/bin/env bash
echo "Linking:"
echo "  ~/Dropbox/Apps/vscode -> ~/.vscode"
echo "  ~/Dropbox/Apps/vscode_application_support -> ~/Library/Application Support/Code"
ln -nsf "~/Dropbox/Apps/vscode" ~/.vscode
ln -nsf "~/Dropbox/Apps/vscode_application_support" ~/Library/Application\ Support/Code
