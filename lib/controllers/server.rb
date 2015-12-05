$LOAD_PATH.unshift(File.dirname(__FILE__))
Dir.chdir("../")
require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require 'yaml'
require 'controllers/helpers'

include Helpers
CONFIG = YAML::load_file('../config/config.yml')

set :server, :puma
set :port, CONFIG['server_port']
set :root, File.dirname(__FILE__)

puts "Initializing DB ..."
init = Tracker.new
sleep 2

get '/' do
  format_html(erb :index)
end

get '/entry' do
  content_type :json
  atc = Controller.new
  atc.register(params[:flight] || 0)
end

get '/tracking_info' do
  content_type :json
  tracker = Tracker.new
  tracker.active_positions(params[:timeframe].to_i || 720)
end

get '/realtime_metrics' do
  tracker = Tracker.new
  [ tracker.dashboard_metrics,
    render_table_data(tracker.data_table(:inflight)),
    render_table_data(tracker.data_table(:log)),
    tracker.get_tracker_array
  ].to_s
end

get '/flight_details' do
  tracker = Tracker.new
  add_labels(tracker.detailed_flight_info(params[:id].to_i), 1).to_s
end

get '/version' do
  CONFIG['version'].to_s
end

get '/css/flighttracker.css' do
  send_file 'views/css/flighttracker.css'
end

get '/js/flighttracker.js' do
  send_file 'views/js/flighttracker.js'
end

not_found do
  format_html(erb :not_found)
end

after do
  ActiveRecord::Base.connection.close
end
