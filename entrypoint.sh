#!/bin/sh
set -e
echo "Exporting GEM_HOME, setting it to $(ruby -e 'puts Gem.user_dir')"
export GEM_HOME="$(ruby -e 'puts Gem.user_dir')"
echo "Adding GEM_HOME/bin to PATH"
export PATH="$PATH:$GEM_HOME/bin"
echo "New PATH: $PATH"
echo "Launching the tex scanning and compilation proces..."
/entrypoint.rb
