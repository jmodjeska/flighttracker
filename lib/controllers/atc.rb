$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'models/queries'
require 'models/constructor'

class Controller
include Queries
include Constructor

  CONS = YAML::load_file("../config/constants.yml")
  attr_accessor :ingress_time, :flight_speed

  def initialize(flight_code, altitude = 10000)
    @ingress_time, @altitude = Time.now, altitude
    db_up
    prime_database
    record_flight_entry(flight_code, @ingress_time)
  end

  def decision
    @flight_speed = assign_descent_speed || 0
    if @flight_speed >= CONS['descent_min']
      if record_accepted_flight
        return { :decision => 'accepted', :speed => @flight_speed }
      else
        return { :decision => 'ERROR. Could not record flight info.' }
      end
    else
      update_flight_info('action', 'diverted')
      return { :decision => 'diverted' }
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

  def record_accepted_flight
    flight_info = {
      :action => 'accepted',
      :ingress_altitude => @altitude,
      :descent_speed => @flight_speed,
      :final_approach_time => @ingress_time + time_ingress_to_fa(@flight_speed),
      :landing_time => @ingress_time +
        time_ingress_to_fa(@flight_speed) + time_fa_to_land(@flight_speed)
    }
    return true if flight_info.each { |k, v| update_flight_info(k, v) }
  end
end
