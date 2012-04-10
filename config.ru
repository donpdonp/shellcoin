# config.ru
require 'shell_coin.rb'

map "/shell" do
  run ShellCoin
end
