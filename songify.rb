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
        Songify::Album.new(data[0], data[1], data[2], data[3], data[4])
      end

    end
    
    def self.clear_data 
      # TODO: implement
    end
  end
end

# require all lib/ entities and repos files here