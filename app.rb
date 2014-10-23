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

DataMapper.setup( :default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/my_shortened_urls.db" )
DataMapper::Logger.new($stdout, :debug)
DataMapper::Model.raise_on_save_failure = true 

require_relative 'model'

DataMapper.finalize
DataMapper.auto_upgrade!

Base = 36


use OmniAuth::Builder do
  config = YAML.load_file 'config/config.yml'
#   config = YAML.load_file 'config/config_local.yml'
  provider :google_oauth2, config['identifier'], config['secret']
end

enable :sessions
set :session_secret, '*&(^#234a)'

get '/' do
    haml :signin
end


get '/auth/:name/callback' do
    config = YAML.load_file 'config/config.yml'
# 	config = YAML.load_file 'config/config_local.yml'
    case params[:name]
    when 'google_oauth2'
      session[:auth] = @auth = request.env['omniauth.auth']
      session[:name] = @auth['info'].name
	  session[:image] = @auth['info'].image
	  session[:email] = @auth['info'].email
      redirect "user/index"
    else
      redirect "/auth/failure"
    end
end

get '/user/:webname' do
  if (session[:name] != nil)
    case(params[:webname])
    when "index"
      @user = session[:name]
	  @user_img = session[:image]
	  email = session[:email]
#       @list = ShortenedUrl.all(:order => [ :id.asc ], :limit => 20)
	  @list = ShortenedUrl.all(:order => [:id.asc], :email => email , :limit => 20)
      haml :index
    end
  else
    redirect '/'
  end
end


post '/user/:webname' do
#   puts "inside post '/': #{params}"
  if (session[:name] != nil)
    uri = URI::parse(params[:url])
    if uri.is_a? URI::HTTP or uri.is_a? URI::HTTPS then
      begin
# 		 @short_url = ShortenedUrl.first_or_create(:url => params[:url],:label => params[:label])
		 @short_url = ShortenedUrl.first_or_create(:url => params[:url] , :email => session[:email] , :label => params[:label])
		 rescue Exception => e
		 puts "EXCEPTION!!!!!!!!!!!!!!!!!!!"
		 pp @short_url
		 puts e.message
      end
    else
      logger.info "Error! <#{params[:url]}> is not a valid URL"
    end
    redirect '/user/index'
  end
  redirect '/'
end


get '/user/index/logout' do
  puts "SALIENDO...."
  if session[:auth]
    session[:auth] = nil;
  end
  session.clear
  redirect '/'
end


get '/user/index/close_sesion' do
  session.clear
  redirect 'https://accounts.google.com/Logout'
end


get '/user/index/:shortened' do
  puts "inside get '/user/index/:shortened': #{params}"
  short_url = nil
  short_url = ShortenedUrl.first(:label => params[:shortened])
#   short_url = ShortenedUrl.first((:label => params[:shortened]) && (:usu => @usu))
  if short_url == nil
	 short_url = ShortenedUrl.first(:id => params[:shortened].to_i(Base))
# 	 short_url = ShortenedUrl.first((:id => params[:shortened].to_i(Base)) && (:usu => @usu))
  end
=begin
  if (params[:label] == "")
    puts "ENTRO EN 1"
    short_url = ShortenedUrl.first(:id => params[:shortened].to_i(Base))
  else
    puts "ENTRO EN 2"
    short_url = ShortenedUrl.first(:label => params[:shortened])
   end
=end
  redirect short_url.url, 301
end


get '/auth/failure' do
  flash[:notice] =
    %Q{<h3>Se ha producido un error</h3>}
  redirect '/'
end

error do haml :signin end
