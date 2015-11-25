$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'models/queries'
require 'models/constructor'

class Tracker
include Queries
include Constructor

  def initialize(timeframe)
    @timeframe = timeframe
    db_up
    prime_database
  end

  def active_positions
    aircrafts = []
    recent_planes(@timeframe).each do |flight|
      info = {}
      info['flight'] = flight['flight_code']

      if flight['action'] == 'diverted'
        info['status'] = 'diverted'
      else
        status = find_status( flight['id'] )
        if status == 'landed'
          info['x'], info['y'], info['altitude'] = 0, 20000, 0
        else
          speed      = flight['descent_speed']
          start_alt  = flight['ingress_altitude']
          start_time = flight['ingress_time']
          end_time   = Time.now
          distance   = distance_traveled( speed, start_time, end_time )
          info['x'], info['y'] = position( start_alt, distance )
          info['altitude'] = altitude( start_alt, start_time, end_time, speed )
        end
        info['status'] = status
      end

      aircrafts << info
    end
    return { 'aircrafts' => aircrafts }.to_json
  end

  def find_status(id)
    case
    when plane_info_by_id( id, :landing_time ) < Time.now
      return 'landed'
    when plane_info_by_id( id, :final_approach_time ) < Time.now
      return 'final_approach'
    else
      return 'descent'
    end
  end
end
