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
  @album = Songify::AlbumRepo.add_album(params["album-title"], params["album-year"], params["album-genre"], params["album-cover"])
  if @album.nil?
    "HERMANO, YO ALBUM ALREADY BEEN ALL UP IN MY DATABASES"
  else
    erb :album_detail
  end
end

post '/album/add-tracks' do
  # track_list = params.select {|k,v| k.to_s.match(/track/)}
  track = params[:track1]
  album_id = params[:album_id]
  Songify::TrackRepo.add_tracks(track, album_id)
  redirect to("/album/#{album_id}")
end

get '/album/:id' do
  @id = params[:id]
  
  logic = /^[0-9]*$/
  check_if_num = logic.match(@id) #check if id is a number

  if check_if_num
    @album = Songify::AlbumRepo.get_single_album(@id)
    @tracks = Songify::TrackRepo.get_tracks(@id)
    p @tracks
    if @album.nil?
      "This album does not exist."
    else
      erb :album_detail
    end

  else
    "ID should be a number"
  end
end

# {"album-title"=>"asd", "track-1"=>"asd", "track-2"=>"", "track-3"=>"", "track-4"=>"", "track-5"=>"", "track-6"=>"", "track-7"=>"", "track-8"=>"", "track-9"=>"", "track-10"=>""}
# params.to_s