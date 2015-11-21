$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'rubygems'
require 'bundler/setup'

class Simulator
  CONFIG = YAML::load_file("../config/config.yml")

  def initialize(run_mode=:realtime)
    @run_mode = run_mode
  end

  def flight_code
    airline = File.readlines('../data/iata_codes.txt').sample[0..1]
    number = rand(100..9999).to_s
    return airline + number
  end

  def altitude
    rand(10000..12000)
  end

  def generate_query_string
    "#{CONFIG['server_url']}/entry?flight=#{flight_code}&altitude=#{altitude}"
  end
end
