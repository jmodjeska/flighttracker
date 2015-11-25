$LOAD_PATH.unshift(File.dirname(__FILE__))
Dir.chdir("../")
require 'webrick'
require 'yaml'
require 'htmlbeautifier'
require 'nokogiri'
require 'controllers/response_builder'

class FlightServer < WEBrick::HTTPServlet::AbstractServlet
include Builder

  def do_GET(request, response)
    status, content_type, body = route(request)
    response.status = status
    response['Content-Type'] = content_type
    response.body = body
  end

  def route(request)
    if request.path == '/entry'
      page_content = entry_response_json
      return [200, 'application/json', page_content]
    elsif request.path == '/tracking_info'
      page_content = tracker_json
      return [200, 'application/json', page_content]
    elsif request.path == '/'
      page_content = fancy_webpage
      return [200, 'text/html', page_content]
    else
      page_content = not_found_html
      return [404, 'text/html', page_content]
    end
  end
end

CONFIG = YAML::load_file('../config/config.yml')
server = WEBrick::HTTPServer.new( :Port => CONFIG['server_port'] )
server.mount '/', FlightServer
trap('INT') { server.shutdown }
server.start
