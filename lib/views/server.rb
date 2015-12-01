$LOAD_PATH.unshift(File.dirname(__FILE__))
Dir.chdir("../")
require 'webrick'
require 'yaml'
require 'htmlbeautifier'
require 'nokogiri'
require 'controllers/atc'
require 'controllers/tracker'
require 'controllers/routes'

class FlightServer < WEBrick::HTTPServlet::AbstractServlet
include Routes

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
end

CONFIG = YAML::load_file('../config/config.yml')
puts "Initializing DB ..."
atc = Tracker.new(0)
sleep 3
server = WEBrick::HTTPServer.new( :Port => CONFIG['server_port'] )
server.mount '/', FlightServer
trap('INT') { server.shutdown }
server.start
