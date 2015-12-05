$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'rubygems'
require 'bundler/setup'
require 'net/http'
require 'net/ping'
require 'yaml'
require 'controllers/atc'
require 'controllers/tracker'
require 'models/constructor'

class Simulator
include Constructor

  CONFIG = YAML::load_file('../config/config.yml')
  CONS = YAML::load_file('../config/constants.yml')

  def initialize(run_mode = nil)
    host, port = CONFIG['server_url'], CONFIG['server_port']
    @server = "http://#{host}:#{port}"
    test = Net::Ping::TCP.new(host, port, 5)
    unless test.ping?
      abort("Can't connect to #{host} on port #{port}. Is the server running?")
    end
    send_in_the_planes if run_mode == :realtime
  end

  def flight_code
    airline = File.readlines('../data/iata_codes.txt').sample[0..1]
    number = rand(100..9999).to_s
    return airline + number
  end

  def generate_query_string
    "#{@server}/entry?flight=#{flight_code}&altitude=#{CONS['ingress_alt']}"
  end

  def send_plane
    request = URI(generate_query_string)
    puts "Sending #{request} ..."
    response = Net::HTTP.get(request)
    if response.match(/error/)
      # Hack to reduce transient ActiveRecord errors that I can't diagnose
      puts "-=> Received error response; trying again\n\n"
      response = Net::HTTP.get(request)
    end
    puts "-=> Received #{response}\n\n"
    return response
  end

  def send_in_the_planes
    puts "Running simulator. Control+C to break."
    loop do
      send_plane
      delay = rand(20..48)
      delay.times do |sec|
        print " Waiting #{delay - sec} seconds ...\r"
        $stdout.flush
        sleep 1
      end
    end
  end
end

run_mode = ARGV[0]

if run_mode.nil?
  puts "Command line usage: ruby #{$0} realtime"
elsif run_mode == 'realtime'
  sim = Simulator.new(:realtime)
else
  sim = Simulator.new
end
