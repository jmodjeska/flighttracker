require 'yaml'

module Calculations

  CONS = YAML::load_file("../config/constants.yml")

  def distance_traveled(speed, start_time, end_time)
    speed * ( end_time - start_time ).to_f
  end

  def total_descent(ingress_altitude)
    ingress_altitude - CONS['fa_altitude']
  end

  def slope(ingress_altitude)
    ( ingress_altitude.to_f - CONS['fa_altitude'] ) /
      ( CONS['descent_h_distance'] )
  end

  def get_x(d)
    (-2.1e-12 * d**3) - (4.41e-6 * d**2) + (0.047 * d) + 16000
  end

  def get_y(d)
    (2.23e-14 * d**4) - (2e-9 * d**3) + (1.022e-4 * d**2) - (5 * d) + 47000
  end

  def position(ingress_altitude, raw_distance, speed)
    s = slope( ingress_altitude )
    d = Math.sqrt( raw_distance.to_f**2 / ( 1 + s**2 ) )
    if ( get_x(d) < CONS['landing_x'] )
      return final_approach_position(d)
    else
      return [get_x(d), get_y(d)]
    end
  end

  def final_approach_position(d)
    x = CONS['landing_x']
    max_y = get_y( CONS['descent_distance'] + CONS['fa_distance'] )

    # The position formula doesn't terminate exactly at 0,0 for FA, so
    # I'm using zero in place of a negative y coordinate; this prevents
    # ratios with negative numerators.
    y = [get_y(d), 0].max

    # For reasons I can't figure out, sometimes the y value is slightly
    # more than the max distance. Until I can figure out why, I'm
    # limiting the ratio to 1 so planes don't go backwards.
    y_ratio = [( y / max_y ), 1].min

    return [x, ( CONS['landing_y'] * y_ratio )]
  end

  def time_ingress_to_fa(speed)
    CONS['descent_distance'].to_f / speed
  end

  def time_fa_to_land(speed)
    ( 2 * CONS['fa_distance'].to_f ) / ( speed + CONS['landing_speed'] )
  end

  def current_speed_fa(time_at_fa, end_time, speed)
    elapsed_time = end_time - time_at_fa
    decel_rate = ( speed - CONS['landing_speed'] ) / time_fa_to_land(speed)
    return ( speed - ( decel_rate * elapsed_time ) ).to_i
  end

  def altitude(ingress_altitude, ingress_time, end_time, speed)

    # Altitude calculation during regular descent
    if ( speed * ( end_time - ingress_time ) ) <= CONS['descent_distance']
      descent_duration = ( CONS['descent_distance'].to_f / speed )
      descent_rate = ( total_descent( ingress_altitude ) / descent_duration )
      return ingress_altitude - ( ( end_time - ingress_time ) * descent_rate )

    # Altitude calculation during final approach
    else
      descent_rate = ( CONS['fa_altitude'] / time_fa_to_land(speed) )
      return CONS['fa_altitude'] - ( ( end_time -
        ( ingress_time + time_ingress_to_fa( speed ) ) ) * descent_rate )
    end
  end
end
