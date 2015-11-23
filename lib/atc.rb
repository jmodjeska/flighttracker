$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'models/queries'
require 'models/constructor'

class Controller
include Queries
include Constructor

  CONS = YAML::load_file("../config/constants.yml")
  attr_accessor :ingress_time

  def initialize(flight_code, altitude = 10000)
    @ingress_time, @altitude = Time.now, altitude
    db_up
    prime_database
    record_flight_entry(flight_code, @ingress_time)
    atc_decision
  end

  def atc_decision
    speed = assign_descent_speed
    if ( speed >= CONS['descent_min'] ) &&
      ( check_current_proximity > CONS['min_distance'] )
      @flight_speed = speed
      update_atc_decision('action', 'accepted')
      update_atc_decision('descent_speed', @flight_speed)
    else
      update_atc_action('diverted')
    end
  end

  def check_current_proximity
    distance_traveled( speed_last_plane,
      time_last_plane_at_ingress, @ingress_time )
  end

  def assign_descent_speed
    if time_last_plane_at_fa < Time.now
      return CONS['descent_max']
    else
      proximities = {}
      CONS['descent_min'].upto(CONS['descent_max']) do |speed|
        projected_distance = distance_traveled( speed,
          time_last_plane_at_fa, @ingress_time )
        buffer = CONS['descent_distance'] - projected_distance
        proximities[speed] = buffer if buffer > CONS['min_distance']
      end
      return proximities.keys.max.to_i
    end
  end
end
