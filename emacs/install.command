#!/usr/bin/env bash

set -e

BASEDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"

# Check if the `emacs` file exists in the script's directory
if [ ! -f "$BASEDIR/emacs" ]; then
  echo "The file './emacs' does not exist in the script's directory."
  exit 1
fi

echo "Linking ./emacs -> ~/.emacs"
ln -nsf "$BASEDIR/emacs" ~/.emacs

emacs --batch \
      --eval "(require 'package)" \
      --eval "(add-to-list 'package-archives '(\"melpa\" . \"https://melpa.org/packages/\"))" \
      --eval "(package-initialize)" \
      --eval "(package-refresh-contents)" \
      --eval "(package-install (quote color-theme-sanityinc-tomorrow))" \
      --eval "(package-install (quote no-littering))" \
      --eval "(package-install (quote move-text-default-bindings))"
