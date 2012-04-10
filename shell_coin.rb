require 'sinatra/base'
require "sinatra/reloader"
require 'slim'
require 'sqlite3'
require 'bitbank'

class ShellCoin < Sinatra::Base
  @@path = File.dirname(__FILE__)
  @@sql = SQLite3::Database.new("#{@@path}/usercoins.db")
  @@config = YAML.load(File.open("#{@@path}/config.yml"))
  @@bitcoin =  Bitbank.new(@@config["bitbank"])

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
    @block_count = @@bitcoin.block_count
    slim :index
  end

  post '/' do
    if !params[:username].blank? && !params[:ssh_key].blank?
      username = params[:username].gsub(/ /,'')
      user = load(username)
      unless user
        account = @@bitcoin.new_account('shellcoin-'+username)
        @@sql.execute("insert into users (username, ssh_key, bitcoin_address) values (?,?,?)", 
                      username, params[:ssh_key], account.address)
      end
      redirect to("/#{username}")
    else
      redirect to("/")
    end
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
