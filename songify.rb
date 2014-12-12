require 'pg'

module Songify
  class Album
    attr_reader :id, :title
    def initialize(id, title)
      @id = id
      @title = title
    end
  end
  
  class AlbumRepo
    @@db = PG.connect(dbname: 'songify-db')
    
    def self.create_table
      command = <<-SQL
      CREATE TABLE IF NOT EXISTS albums(
        id SERIAL,
        title text,
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
        Songify::Album.new(data[0], data[1])
      end

    end

    def self.get_albums
      command = <<-SQL
      SELECT * FROM albums;
      SQL

      result = @@db.exec(command)
      result.values.map do |x|
        Album.new(x[0], x[1])
      end
    end

    def self.add_album(title)
      create_table
      command = <<-SQL
      INSERT INTO albums( title )
      SELECT '#{title}' 
      WHERE NOT EXISTS (SELECT * FROM albums WHERE title = '#{title}' )
      RETURNING *;
      SQL

      result = @@db.exec(command)
      data = result.values[0]
      
      if data.nil?
        return nil
      else
        Songify::Album.new(data[0], data[1])
      end

    end
    
    def self.clear_data 
      # TODO: implement
    end
  end
end

# require all lib/ entities and repos files here