$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'active_record'
require 'pg'
require 'yaml'

module Constructor

  SCHEMA = YAML::load_file('models/db_schema.yml')
  CONFIG_SECRET = YAML::load_file('../config/config_secret.yml')

  def db_up
    access_db
    create_table_schema
    return ActiveRecord::Base
  end

  def access_db
    ActiveRecord::Base.logger = Logger.new("../data/flighttracker.log")
    ActiveRecord::Base.default_timezone = :local
    db = URI.parse(CONFIG_SECRET['db_url'] || ENV['DATABASE_URL'])
    pool = ENV["DB_POOL"] || ENV['MAX_THREADS'] || 5
    ActiveRecord::Base.establish_connection(
      :adapter  => 'postgresql',
      :host     => db.host,
      :username => db.user,
      :password => db.password,
      :database => db.path[1..-1],
      :encoding => 'utf8',
      :pool     => pool
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
