$LOAD_PATH.unshift(File.dirname(__FILE__))
Dir.chdir("../")
require 'webrick'
require 'yaml'
require 'htmlbeautifier'
require 'nokogiri'
require 'controllers/atc'
require 'controllers/tracker'

class FlightServer < WEBrick::HTTPServlet::AbstractServlet

  CONFIG = YAML::load_file('../config/config.yml')

  def do_GET(request, response)
    status, content_type, body = route(request)
    response.status = status
    response['Content-Type'] = content_type
    if content_type == 'text/html'
      body = HtmlBeautifier.beautify(Nokogiri::HTML(body).to_html)
    end
    response.body = body
  end

  def check_for_simulator
    return ( `pgrep -f simulator.rb`.split("\n").length > 0 ) ? "ON" : "OFF"
  end

  def not_found
    '<h1>Not Found</h1>'
  end

  def render_table_data(data_array)
    label_color = {
      'descent'        => 'primary',
      'final_approach' => 'primary',
      'diverted'       => 'warning',
      'error'          => 'danger',
      'landed'         => 'success',
      'test'           => 'gray'
    }
    th = data_array[0].map { |th| "<th>#{th}</th>" }
    td = data_array[1].map do |tr|
      "<tr>" +
      tr.map.with_index do |td, i|
        if i == ( tr.length - 1 )
          "<td><button type=\"button\" class=\"btn btn-#{label_color[td]} " +
          "btn-xs\">#{td.gsub('_', ' ').split.map(&:capitalize).join(' ')}" +
          "</button></td>"
        else
        "<td>#{td}</td>"
        end
      end.join +
      "</tr>"
    end
    thead = "<thead><tr>#{th.join}</tr></thead>"
    tbody = "<tbody>#{td.join}</tbody>"
    return thead + tbody
  end

  def route(request)
    case request.path
    when '/entry'
      page_content = '{ "decision": "ERROR. Missing flight code." }'
      if request.query["flight"]
        atc = Controller.new(request.query["flight"],
          request.query["altitude"])
        page_content = atc.decision.to_json
      end
      return [200, 'application/json', page_content]
    when '/tracking_info'
      timeframe = request.query["timeframe"] || 720
      tracker = Tracker.new(timeframe.to_i)
      page_content = tracker.active_positions
      return [200, 'application/json', page_content]
    when '/realtime_tracking_info'
      tracker = Tracker.new(0)
      page_content = tracker.get_tracker_array.to_s
      return [200, 'text/plain', page_content]
    when '/realtime_metric_info'
      tracker = Tracker.new(0)
      page_content = tracker.dashboard_metrics.to_s
      return [200, 'text/plain', page_content]
    when '/realtime_inflight_info'
      tracker = Tracker.new(0)
      page_content = render_table_data(tracker.datatable(:inflight))
      return [200, 'text/plain', page_content]
    when '/realtime_log_info'
      tracker = Tracker.new(0)
      page_content = render_table_data(tracker.datatable(:log))
      return [200, 'text/plain', page_content]
    when '/version'
      return [200, 'text/plain', CONFIG['version'].to_s]
    when '/server_time'
      return [200, 'text/plain', Time.now.to_s[0..18]]
    when '/sim_status'
      return [200, 'text/plain', check_for_simulator]
    when '/'
      index = File.open('views/index.html', 'rb')
      page_content = index.read
      return [200, 'text/html', page_content]
    else
      return [404, 'text/html', not_found]
    end
  end
end

CONFIG = YAML::load_file('../config/config.yml')
puts "Initializing DB ..."
atc = Tracker.new(0)
sleep 3
server = WEBrick::HTTPServer.new( :Port => CONFIG['server_port'] )
server.mount '/', FlightServer
trap('INT') { server.shutdown }
server.start
