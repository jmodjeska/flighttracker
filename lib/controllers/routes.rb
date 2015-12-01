$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'controllers/atc'
require 'controllers/tracker'

module Routes

  CONFIG = YAML::load_file('../config/config.yml')

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
