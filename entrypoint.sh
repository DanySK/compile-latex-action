#!/bin/sh
set -e
#echo "Computing the ruby version"
#RUBY_VERSION="$(/\/([\d\.]+)$/.match(Gem.user_dir)[1])"
#ROOT_GEM_HOME="/root/.local/share/gem/ruby/$RUBY_VERSION/bin"
#echo "Forcing directory ${ROOT_GEM_HOME} as a valid Gem install lookup place"
#export PATH="$PATH:$ROOT_GEM_HOME"
echo "Exporting GEM_HOME, setting it to $(ruby -e 'puts Gem.user_dir')"
export GEM_HOME="$(ruby -e 'puts Gem.user_dir')"
echo "Adding GEM_HOME/bin to PATH"
export PATH="$PATH:$GEM_HOME/bin"
echo "New PATH: $PATH"
echo "Exporting ROOT_GEM_HOME, setting it to $(sudo ruby -e 'puts Gem.user_dir')"
export ROOT_GEM_HOME="$(sudo ruby -e 'puts Gem.user_dir')"
echo "Adding ROOT_GEM_HOME/bin to PATH"
export PATH="$PATH:$ROOT_GEM_HOME/bin"
echo "New PATH: $PATH"
echo "Launching the tex scanning and compilation proces..."
/entrypoint.rb
