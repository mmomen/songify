require 'pg'

module Songify
  class Album
    attr_reader :id, :title, :year, :genre, :cover
    def initialize(id, title, year, genre, cover)
      @id = id
      @title = title
      @year = year
      @genre = genre
      @cover = cover
    end
  end
  
  class Track
    attr_reader :id, :track_title, :album_id
    def initialize(id, track_title, album_id)
      @id = id
      @track_title = track_title
      @album_id = album_id
    end
  end

  class AlbumRepo
    @@db = PG.connect(dbname: 'songify-db')
    
    def self.create_table
      command = <<-SQL
      CREATE TABLE IF NOT EXISTS albums(
        id SERIAL,
        title TEXT,
        year INTEGER,
        genre TEXT,
        cover TEXT,
        PRIMARY KEY( id )
      );
      SQL

      @@db.exec(command)
    end

    def self.get_single_album(id)
      command = <<-SQL
      SELECT * FROM albums
      WHERE id = #{id}
      LIMIT 1;
      SQL

      result = @@db.exec(command)
      data = result.values[0]

      if data.nil?
        return nil
      else
        Songify::Album.new(data[0], data[1], data[2], data[3], data[4])
      end
    end

    def self.get_albums
      create_table
      command = <<-SQL
      SELECT * FROM albums;
      SQL

      result = @@db.exec(command)
      result.values.map do |x|
        Album.new(x[0], x[1], x[2], x[3], x[4])
      end
    end

    def self.add_album(title, year, genre, cover)
      create_table
      command = <<-SQL
      INSERT INTO albums( title, year, genre, cover )
      SELECT '#{title}', '#{year}', '#{genre}', '#{cover}' 
      WHERE NOT EXISTS (SELECT * FROM albums WHERE title = '#{title}' )
      RETURNING *;
      SQL

      result = @@db.exec(command)
      data = result.values[0]
      if data.nil?
        return nil
      else
        Album.new(data[0], data[1], data[2], data[3], data[4])
      end
    end

    def self.edit_album_details(id, title, year, genre, cover)
      command = <<-SQL
      UPDATE albums
      SET title = '#{title}', year = '#{year}', genre = '#{genre}', cover = '#{cover}'
      WHERE albums.id = #{id}
      RETURNING *;
      SQL

      result = @@db.exec(command)
      data = result.values[0]

      Album.new(data[0], data[1], data[2], data[3], data[4])
    end
  end

  class TrackRepo
    @@db = PG.connect(dbname: 'songify-db')

    def self.create_table
      command = <<-SQL
      CREATE TABLE IF NOT EXISTS tracks(
        id SERIAL,
        track_title TEXT,
        PRIMARY KEY( id ),
        album_id INTEGER REFERENCES albums( id )
      );
      SQL

      @@db.exec(command)
    end

    def self.add_tracks(track, album_id)
      create_table
      command = <<-SQL
      INSERT INTO tracks( track_title, album_id )
      VALUES ( '#{track}', '#{album_id}' )
      RETURNING *;
      SQL

      @@db.exec(command)
    end

    def self.get_tracks(album_id)
      create_table
      command = <<-SQL
      SELECT * FROM tracks 
      WHERE album_id = '#{album_id}'
      ORDER BY id;
      SQL

      result = @@db.exec(command)

      # if result.nil?
        # return nil
      # else
      # p result.values
        result.values.map do |x|
          Track.new(x[0], x[1], x[2])
        # end
      end
    end

    def self.edit_track(track_id, new_track_title)
      command = <<-SQL
      UPDATE tracks
      SET track_title = '#{new_track_title}'
      WHERE tracks.id = #{track_id};
      SQL

      @@db.exec(command)

    end
  end
end