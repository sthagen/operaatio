#! /usr/bin/env bash
# WIP
git clone https://github.com/rbenv/rbenv.git $HOME/.rbenv
 
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> .bashrc
echo 'eval "$(rbenv init -)"' >> $HOM/.bashrc
exec $SHELL
type rbenv

git clone https://github.com/rbenv/ruby-build.git $HOME/.rbenv/plugins/ruby-build

rbenv install 3.1.2
rbenv global 3.1.2

exec $SHELL
ruby -v

echo "gem: --no-document" > $HOME/.gemrc
gem install bundler
gem env home
gem install bashly
