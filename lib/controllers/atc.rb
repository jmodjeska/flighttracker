$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'models/queries'
require 'models/constructor'

class Controller
include Queries
include Constructor

  CONS = YAML::load_file("../config/constants.yml")
  attr_accessor :ingress_time, :flight_speed, :flight_code

  def register(flight_code)
    if flight_code == 0
      return '{ "decision": "ERROR. Missing flight code." }'
    else
      @ingress_time = Time.now
      @flight_code = flight_code
      return decision.to_json
    end
  end

  def decision
    @flight_speed = assign_descent_speed || 0
    @action = ( @flight_speed >= CONS['descent_min'] ) ? 'accepted' : 'diverted'
    begin
      if register_flight
        return { :decision => @action, :speed => @flight_speed }
      else
        return { :decision => @action }
      end
    rescue Exception => e
      return { :decision => 'Error recording flight info: ' + e.message.to_s }
    end
  end

  def assign_descent_speed
    if last_plane_info( :final_approach_time ).nil? ||
      last_plane_info( :final_approach_time ) < Time.now
      return CONS['descent_max']
    else
      proximities = {}
      CONS['descent_min'].upto(CONS['descent_max']) do |speed|
        projected_distance = distance_traveled( speed,
          @ingress_time, last_plane_info( :final_approach_time ) )
        buffer = CONS['descent_distance'] - projected_distance
        proximities[speed] = buffer if buffer > CONS['min_distance']
      end
      return proximities.keys.max.to_i
    end
  end

  def register_flight
    flight_info = {
      :flight_code => @flight_code,
      :action => @action,
      :ingress_time => @ingress_time
    }
    if @action == 'accepted'
      flight_info[:ingress_altitude] = CONS['ingress_alt']
      flight_info[:descent_speed] = @flight_speed
      flight_info[:final_approach_time] = @ingress_time +
        time_ingress_to_fa(@flight_speed)
      flight_info[:landing_time] = @ingress_time +
          time_ingress_to_fa(@flight_speed) + time_fa_to_land(@flight_speed)
    end
    return true if record_flight_entry( flight_info )
  end
end
