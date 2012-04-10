require 'sinatra/base'
require "sinatra/reloader"
require 'slim'
require 'sqlite3'

class ShellCoin < Sinatra::Base
  @@path = File.dirname(__FILE__)
  @@sql = SQLite3::Database.new("#{@@path}/usercoins.db")

  @@sql.execute <<-SQL
  create table if not exists users (
      username text,
      ssh_key text,
      bitcoin_address text
  );
  create table if not exists history (
      username text,
      note text
  );
  SQL

  configure do
    set :sessions, true
    set :slim, :pretty => true

    register Sinatra::Reloader
  end

  get '/' do
    puts "wtf"
    @count = @@sql.execute( "select count(*) from users")[0][0]
    slim :index
  end

  post '/' do
    redirect to("/#{params[:username]}")
  end

  get '/:username' do
    @user = @@sql.execute("select * from users where username = ?", params[:username])

    slim :show
  end
end