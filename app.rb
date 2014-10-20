#!/usr/bin/env ruby
require 'bundler/setup'
require 'sinatra'
require 'sinatra/reloader' if development?
require 'omniauth-oauth2'
require 'omniauth-google-oauth2'
require 'pry'
require 'haml'
require 'rubygems'
require 'uri'
require 'data_mapper'

require 'erubis'
require 'pp'

# set :erb, :escape_html => true

DataMapper.setup( :default, ENV['DATABASE_URL'] || 
                            "sqlite3://#{Dir.pwd}/my_shortened_urls.db" )
DataMapper::Logger.new($stdout, :debug)
DataMapper::Model.raise_on_save_failure = true 

require_relative 'model'

DataMapper.finalize
DataMapper.auto_upgrade!

Base = 36



use OmniAuth::Builder do
  config = YAML.load_file 'config/config.yml'
  provider :google_oauth2, config['identifier'], config['secret']
end

enable :sessions
set :session_secret, '*&(^#234a)'

get '/' do
    haml :signin
#   erb :index
#   %Q|<a href='/auth/google_oauth2'>Sign in with Google</a>|
end

get '/auth/:name/callback' do
  puts "inside get '/': #{params}"
  @list = ShortenedUrl.all(:order => [ :id.asc ], :limit => 20)
  # in SQL => SELECT * FROM "ShortenedUrl" ORDER BY "id" ASC
  haml :index
=begin
  @auth = request.env['omniauth.auth']
  puts "params = #{params}"
  puts "@auth.class = #{@auth.class}"
  puts "@auth info = #{@auth['info']}"
  puts "@auth info class = #{@auth['info'].class}"
  puts "@auth info name = #{@auth['info'].name}"
  puts "@auth info email = #{@auth['info'].email}"
  #puts "-------------@auth----------------------------------"
  #PP.pp @auth
  #puts "*************@auth.methods*****************"
  #PP.pp @auth.methods.sort
#   erb :index
  redirect "/myapp"
#   nombre = @auth['info'].name
#   nombre.gsub!(/\s+/, "") #quitamos los espacios en blanco
#   redirect "/myapp/#{nombre}"
=end
end


post '/auth/:name/callback' do
  puts "inside post '/': #{params}"
  uri = URI::parse(params[:url])
  if uri.is_a? URI::HTTP or uri.is_a? URI::HTTPS then
    begin
      @short_url = ShortenedUrl.first_or_create(:url => params[:url],:label => params[:label])
    rescue Exception => e
      puts "EXCEPTION!!!!!!!!!!!!!!!!!!!"
      pp @short_url
      puts e.message
    end
  else
    logger.info "Error! <#{params[:url]}> is not a valid URL"
  end
#   haml :index
  redirect 'index'
end

get '/auth/:name/callback/:shortened' do
  puts "inside get '/:shortened': #{params}"
  if (params[:label] == '')
   short_url = ShortenedUrl.first(:label => params[:shortened])
  else
   short_url = ShortenedUrl.first(:id => params[:shortened].to_i(Base))
  end
  redirect short_url.url, 301
end

error do haml :index end
