#!/bin/sh
echo "Linking ./../vscode -> ~/.vscode..."
echo "Linking ./../vscode_application_support -> ~/Library/Application\ Support/Code"
BASEDIR=$(greadlink -f $(dirname $0))
ln -nsf "$BASEDIR/../../vscode" ~/.vscode
ln -nsf "$BASEDIR/../../vscode_application_support" ~/Library/Application\ Support/Code

