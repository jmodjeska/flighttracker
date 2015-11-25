$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'yaml'

module Calculations

  CONS = YAML::load_file("../config/constants.yml")

  def elapsed_time_since_ingress
    Time.now - @ingress_time
  end

  def elapsed_time_since_fa
    Time.now - @ingress_time - time_ingress_to_fa
  end

  def distance_since_ingress
    @flight_speed * elapsed_time_since_ingress
  end

  def descent_slope
    ( @ingress_altitude - CONS['fa_altitude'] ) / CONS['descent_distance']
  end

  def descent_duration
    CONS['descent_distance'] / @flight_speed
  end

  def total_descent
    @ingress_altitude - CONS['fa_altitude']
  end

  def distance_traveled(speed, start_time, end_time)
    speed * ( end_time - start_time )
  end

  def horizontal_distance_traveled
    Math.sqrt( distance_traveled**2 / ( 1 + descent_slope**2 ) )
  end

  def position(horizontal_distance_traveled)
    d = horizontal_distance_traveled
    x = (2.1e-12 * d**3) - (4.41e-6 * d**2) + (0.047 * d) + 16000
    y = (2.23e-14 * d**4) - (2e-9 * d**3) + (1.02e-4 * d**2) - (5 * d) + 47000
    return [x, y]
  end

  def time_ingress_to_fa
    CONS['descent_distance'] / @flight_speed
  end

  def time_fa_to_land
    ( 2 * CONS['fa_distance'] ) / ( @flight_speed + CONS['landing_speed'] )
  end

  def current_altitude
    if ( distance_since_ingress <= CONS['descent_distance'] )
      descent_rate = total_descent / descent_duration
      return @ingress_altitude - ( elapsed_time_since_ingress * descent_rate )
    else
      descent_rate = CONS['fa_altitude'] / time_fa_to_land
      return CONS['fa_altitude'] - (elapsed_time_since_fa * descent_rate )
    end
  end
end
