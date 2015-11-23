$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'rubygems'
require 'bundler/setup'
require 'net/http'
require 'yaml'

class Simulator

  CONFIG = YAML::load_file('../config/config.yml')
  CONS = YAML::load_file('../config/constants.yml')

  def initialize(run_mode = nil)
    @server = "http://#{CONFIG['server_url']}:#{CONFIG['server_port']}"
    send_in_the_planes if run_mode == :realtime
  end

  def flight_code
    airline = File.readlines('../data/iata_codes.txt').sample[0..1]
    number = rand(100..9999).to_s
    return airline + number
  end

  def altitude
    rand( CONS['altitude_min']..CONS['altitude_max'] )
  end

  def generate_query_string
    "#{@server}/entry?flight=#{flight_code}&altitude=#{altitude}"
  end

  def send_plane
    request = URI(generate_query_string)
    puts "Sending #{request} ..."
    response = Net::HTTP.get(request)
    puts "-=> Received #{response}\n\n"
  end

  def send_in_the_planes
    puts "Running simulator. Control+C to break."
    loop do
      send_plane
      delay = rand(30..50)
      delay.times do |sec|
        print " Waiting #{delay - sec} seconds ...\r"
        $stdout.flush
        sleep 1
      end
    end
  end
end

run_mode = ARGV[0] || '0'

if run_mode == 'realtime'
  sim = Simulator.new(:realtime)
else
  sim = Simulator.new
end
