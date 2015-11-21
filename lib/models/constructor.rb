$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'active_record'
require 'pg'
require 'yaml'

module Constructor
  CONFIG = YAML::load_file('../config/config.yml')
  SCHEMA = YAML::load_file('models/db_schema.yml')
  DB_URL = ENV['DATABASE_URL'] || CONFIG['database_url']

  def db_up
    access_db
    create_table_schema
    return ActiveRecord::Base
  end

  def access_db
    ActiveRecord::Base.logger = Logger.new('../data/flighttracker.log')
    ActiveRecord::Base.default_timezone = :local
    ActiveRecord::Base.establish_connection(DB_URL)
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
