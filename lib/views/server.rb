$LOAD_PATH.unshift(File.dirname(__FILE__))
Dir.chdir("../")
require 'webrick'
require 'yaml'
require 'htmlbeautifier'
require 'nokogiri'
require 'controllers/atc'
require 'controllers/tracker'
require 'views/html'

class FlightServer < WEBrick::HTTPServlet::AbstractServlet
include HTMLTemplates

  def do_GET(request, response)
    status, content_type, body = route(request)
    response.status = status
    response['Content-Type'] = content_type
    if content_type == 'text/html'
      body_content = html_header + body + html_footer
      body = HtmlBeautifier.beautify(Nokogiri::HTML(body_content).to_html)
    end
    response.body = body
  end

  def route(request)
    if request.path == '/entry'
      page_content = '{ "decision": "ERROR. Missing flight code." }'
      if request.query["flight"]
        atc = Controller.new(request.query["flight"], request.query["altitude"])
        page_content = atc.decision.to_json
      end
      return [200, 'application/json', page_content]
    elsif request.path == '/tracking_info'
      timeframe = request.query["timeframe"] || 720
      tracker = Tracker.new(timeframe.to_i)
      page_content = tracker.active_positions
      return [200, 'application/json', page_content]
    elsif request.path == '/realtime_tracking_info'
      tracker = Tracker.new(0)
      page_content = get_tracker_array(tracker.active_positions).to_s
      return [200, 'text/plain', page_content]
    elsif request.path == '/'
      return [200, 'text/html', fancy_webpage]
    else
      return [404, 'text/html', not_found]
    end
  end
end

CONFIG = YAML::load_file('../config/config.yml')
server = WEBrick::HTTPServer.new( :Port => CONFIG['server_port'] )
server.mount '/', FlightServer
trap('INT') { server.shutdown }
server.start
