require 'active_record'
require 'sqlite3'
require 'yaml'

module Constructor
  SCHEMA = YAML.load_file('models/db_schema.yml')
  DB = '../data/flighttracker.db'


  def db_up
    access_or_create_db
    create_table_schema
    return ActiveRecord::Base
  end

  def access_or_create_db
    SQLite3::Database.new DB unless File.exist?(DB)
    ActiveRecord::Base.logger = Logger.new("../data/flighttracker.log")
    ActiveRecord::Base.default_timezone = :local
    ActiveRecord::Base.establish_connection(
      :adapter  => 'sqlite3',
      :database => DB
    )
  end

  def create_table_schema
    ActiveRecord::Migration.verbose = false
    ActiveRecord::Schema.define do
      SCHEMA.each do |table_def|
        unless ActiveRecord::Base.connection.table_exists? table_def[0]
          create_table table_def[0] do |table|
            table_def[1].each { |col, type| table.column col, type }
          end
        end
      end
    end
  end

  def db_down
    ActiveRecord::Base.clear_active_connections!
  end
end
