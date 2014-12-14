require 'sinatra'
require 'sinatra/json'
require "sinatra/reloader" if development?
require 'pry-byebug'

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
    redirect to("/album/#{@album.id}")
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
  check_if_num = logic.match(@id) #checks if id is a number

  if check_if_num
    @album = Songify::AlbumRepo.get_single_album(@id)
    @tracks = Songify::TrackRepo.get_tracks(@id)

    if @album.nil?
      "This album does not exist."
    else
      erb :album_detail
    end

  else
    "ID should be a number"
  end

end

post '/album/:id/edit-details' do
  @id = params["hidden-album-id"]
  @title = params["edit-album-title"]
  @year = params["edit-album-year"]
  @genre = params["edit-album-genre"]
  @cover = params["edit-album-cover"]

  @album = Songify::AlbumRepo.edit_album_details(@id, @title, @year, @genre, @cover)

  redirect to("/album/#{@id}")
end

post '/album/:album_id/:track_id/edit' do
  @album_id = params[:album_id]
  @track_id = params[:track_id]
  @new_track_title = params["updated-track-name"]

  Songify::TrackRepo.edit_track(@track_id, @new_track_title)

  redirect to("/album/#{@album_id}")
end