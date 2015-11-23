$LOAD_PATH.unshift(File.dirname(__FILE__))
Dir.chdir("../")
require 'webrick'
require 'yaml'
require 'htmlbeautifier'
require 'nokogiri'

class FlightServer < WEBrick::HTTPServlet::AbstractServlet

  CONFIG = YAML::load_file("../config/config.yml")

  def do_GET(request, response)
    response.status = 200
    response['Content-Type'] = 'text/html'
    response.body = "Hello, World."
  end
end

server = WEBrick::HTTPServer.new( :Port => CONFIG['server_port'] )
server.mount '/', FlightServer
trap("INT") { server.shutdown }
server.start
