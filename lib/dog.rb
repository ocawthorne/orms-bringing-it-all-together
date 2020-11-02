require_relative '../config/environment.rb'
require 'pry'

class Dog
    attr_accessor :id, :name, :breed

    def initialize(id: nil, name:, breed:)
        @id, @name, @breed = id, name, breed
    end

    def self.create_table
        sql = <<-SQL
            CREATE TABLE IF NOT EXISTS dogs (
                id INTEGER PRIMARY KEY,
                name TEXT,
                breed TEXT
            );
        SQL

        DB[:conn].execute(sql)
    end

    def self.drop_table
        DB[:conn].execute("DROP TABLE dogs")
    end

    def save
        sql = <<-SQL
            INSERT INTO dogs (name, breed) VALUES (?, ?)
        SQL

        DB[:conn].execute(sql, name, breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        self

    end

    def self.create(dog_hash)
        # binding.pry
        new_dog = self.new(name: dog_hash[:name], breed: dog_hash[:breed])
        new_dog.save
    end

    def self.new_from_db(arg)
        self.new(id: arg[0], name: arg[1], breed: arg[2])
    end

    def self.find_by_id(id_num)
        sql = <<-SQL
            SELECT * FROM dogs WHERE id = ?
            LIMIT 1
        SQL

        new_from_db(DB[:conn].execute(sql, id_num).first)
    end

    def self.find_or_create_by(hash)
        sql = <<-SQL
            SELECT * FROM dogs WHERE (name, breed) = (?, ?)
        SQL

        dog = DB[:conn].execute(sql, hash[:name], hash[:breed]).flatten
        dog = dog.empty? ? self.create(hash) : self.new(id: dog[0], name: dog[1], breed: dog[2])

    end

    def self.find_by_name(name)
        dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ?", name).flatten
        self.new_from_db(dog)
    end

    def update
        sql = <<-SQL
            UPDATE dogs SET name = ?, breed = ? WHERE id = ?
        SQL

        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end



end