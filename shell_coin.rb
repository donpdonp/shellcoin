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
    enable :sessions, :logging
    disable :protection
    set :slim, :pretty => true

    register Sinatra::Reloader
  end

  get '/' do
    @count = @@sql.execute( "select count(*) from users")[0][0]
    slim :index
  end

  post '/' do
    user = load(params[:username])
    unless user
      @@sql.execute("insert into users (username, ssh_key) values (?,?)", 
                    params[:username], params[:ssh_key])
    end
    redirect to("/#{params[:username]}")
  end

  get '/:username' do
    @user = load(params[:username])
    slim :show
  end

  def load(username)
    rows = @@sql.execute("select * from users where username = ?", username)
    rows.first if rows.size > 0
  end
end
