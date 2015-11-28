Dir.chdir("../lib")
require 'minitest/autorun'
require 'net/ping'
require 'net/http'
require 'json'
require_relative '../lib/simulator.rb'

class SimulatorTest < Minitest::Test

  CONFIG = YAML::load_file("../config/config.yml")
  CONS = YAML::load_file("../config/constants.yml")

  def setup
    @server = CONFIG['server_url']
    @port = CONFIG['server_port']
  end

  def test_simulator_generates_query_string
    # Format: http:///entry?flight=DL342&altitude=12000
    rgx = /http:\/\/(.*?)entry\?flight\=[A-Z]{2}\d{3}|\d{4}\&altitude\=\d{5}/
    sim = Simulator.new(:test)
    str = sim.generate_query_string
    sim.db_down
    assert_match rgx, str
  end

  def test_webserver_is_running
    server = Net::Ping::TCP.new(@server, @port, 5)
    assert_equal true, server.ping?
  end

  def test_webserver_responds_with_tracking_info
    # Format http:///tracking_info
    tracking_url = "http://#{@server}:#{@port}/tracking_info"
    request = URI(tracking_url)
    response = Net::HTTP.get(request)
    hash = JSON.parse(response)
    assert_equal true, hash.first[0] == "aircrafts"
  end

  def test_realtime_endpoint_returns_minimum_array
    # Format http:///realtime_tracking_info
    rgx = /^\[\[(.*?)Final Approach(.*?)\]\,\s\[(.*?)Touchdown(.*?)\]\]$/
    tracking_url = "http://#{@server}:#{@port}/realtime_tracking_info"
    request = URI(tracking_url)
    response = Net::HTTP.get(request)
    assert_match rgx, response
  end

  def test_atc_accepts_first_plane
    expected_response = '{"decision":"accepted","speed":128}'
    sim = Simulator.new(:test)
    response = sim.send_plane
    sim.db_down
    assert_equal expected_response, response
  end

  def test_atc_diverts_too_close_plane
    expected_response = '{"decision":"diverted"}'
    response = ''
    sim = Simulator.new(:test)
    5.times { response = sim.send_plane }
    sim.db_down
    assert_equal expected_response, response
  end

  def test_math_fa_alt_at_correct_time
    sim = Simulator.new(:test)
    sim.send_plane
    t = Tracker.new(0)
    current_altitude = t.altitude(
      t.last_plane_info( :ingress_altitude ),
      t.last_plane_info( :ingress_time ),
      ( t.last_plane_info( :ingress_time ) + 510 ),
      t.last_plane_info( :descent_speed )
    )
    sim.db_down
    assert_equal true,
      ( (CONS['fa_altitude'] - 1)..(CONS['fa_altitude'] + 1) ).include?(
        current_altitude.to_i )
  end

  def test_math_plane_lands_at_correct_time
    sim = Simulator.new(:test)
    sim.send_plane
    t = Tracker.new(0)
    current_altitude = t.altitude(
      t.last_plane_info( :ingress_altitude ),
      t.last_plane_info( :ingress_time ),
      ( t.last_plane_info( :ingress_time ) + 510 + 152 ),
      t.last_plane_info( :descent_speed )
    )
    sim.db_down
    assert_equal 0, current_altitude.to_i
  end
end
