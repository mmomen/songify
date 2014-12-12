require 'sinatra'
require 'sinatra/json'
require "sinatra/reloader" if development?

require_relative 'songify.rb'

set :bind, '0.0.0.0' # This is needed for Vagrant

get '/' do
  @albums = Songify::AlbumRepo.get_albums
  erb :index
end

post '/album' do
  @album = Songify::AlbumRepo.add_album(params["album-title"])
  if @album.nil?
    erb :duplicate_album
  else
    erb :album
  end

  # params.to_s
  # "Your album: " + params["album-title"]
end

get '/album/*' do
  
end

# {"album-title"=>"asd", "track-1"=>"asd", "track-2"=>"", "track-3"=>"", "track-4"=>"", "track-5"=>"", "track-6"=>"", "track-7"=>"", "track-8"=>"", "track-9"=>"", "track-10"=>""}