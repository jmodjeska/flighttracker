require 'models/queries'
require 'models/constructor'

class Tracker
include Queries
include Constructor

  def initialize
    db_up
    prime_database
  end

  def active_positions(timeframe = 0)
    aircrafts = []
    planes = ( timeframe == 0 ? airborne_planes : recent_planes(timeframe) )
    planes.each do |flight|
      info = {}
      info['id'] = flight['id']
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
          info['x'], info['y'] = position( start_alt, distance, speed )
          info['altitude'] = altitude( start_alt, start_time, end_time, speed )
        end
        info['status'] = status
      end
      aircrafts << info
    end
    return { 'aircrafts' => aircrafts }.to_json
  end

  def get_airline(iata_code)
    IO.foreach('../data/iata_codes.txt') do |line|
      return line[7..-2].gsub(/\((.*?)$/, '').truncate(50) if
        (line[/^#{iata_code}\b/])
    end
  end

  def get_airline_image(iata_code)
    IO.foreach('../data/iata_images.txt') do |line|
      return line[3..-2] if (line[/^#{iata_code}\b/])
    end
  end

  def get_airline_country(iata_code)
    codes = File.read('../data/iata_codes.txt')
    return codes.match(/^#{iata_code}.*\((.*)\)/)[1]
  end

  def find_status(id)
    begin
      case
      when plane_info_by_id( id, :flight_code )[0..1] == 'XX'
        return 'test'
      when plane_info_by_id( id, :action ) == 'diverted'
        return 'diverted'
      when plane_info_by_id( id, :landing_time ) < Time.now
        return 'landed'
      when plane_info_by_id( id, :final_approach_time ) < Time.now
        return 'final_approach'
      else
        return 'descent'
      end
    rescue Exception => e
      return 'error'
    end
  end

  def icon_rotation(x)
    case
      when x.between?(8800, 11000) then return 225
      when x > 15000 then return 135
      when x > 10000 then return 180
      when x == 0 then return 315
      else return 270
    end
  end

  def get_tracker_array
    tracker_array = JSON.parse(active_positions)['aircrafts'].map do |flight|
      next if flight['x'].nil?
      [ flight['x'],
        flight['y'],
        50, # jqPlot bubble size
        icon_rotation( flight['x'] ),
        flight['flight'],
        flight['altitude'],
        flight['id']
      ]
    end.compact
    return tracker_array
  end

  def data_table(type)
    thead, tbody = [], []
    case type
    when :inflight
      thead, tbody = inflight_table
    when :log
      thead, tbody = log_table
    end
    return [thead, tbody.reverse]
  end

  def log_table
    thead = ['Flight #', 'Airline', 'Ingress Time', 'Status']
    tbody = log_table_data.map do |flight|
      status = find_status(flight.id)
      next if status == 'descent' || status == 'final_approach'
      [ flight.flight_code,
        get_airline( flight.flight_code[0..1] ),
        flight.ingress_time.to_s[0..19],
        status
      ]
    end.compact
    return [thead, tbody]
  end

  def inflight_table
    thead = ['Flight #', 'Airline', 'Speed', 'Altitude', 'Status']
    tbody = airborne_table_data.map do |flight|
      start_alt = flight.ingress_altitude
      start_time = flight.ingress_time
      speed = flight.descent_speed
      altitude = altitude( start_alt, start_time, Time.now, speed )
      if ( flight.final_approach_time <= Time.now )
        speed = current_speed_fa(flight.final_approach_time, Time.now, speed)
      end
      [ flight.flight_code,
        get_airline(flight.flight_code[0..1]),
        speed,
        altitude.to_i,
        find_status(flight.id)
      ]
    end
    return [thead, tbody]
  end

  def detailed_flight_info(id)
    status = find_status(id)
    flight_code = plane_info_by_id(id, 'flight_code')
    [ flight_code,
      status,
      status.split('_').map(&:capitalize).join(' '),
      get_airline_image(flight_code[0..1]),
      get_airline(flight_code[0..1]),
      get_airline_country(flight_code[0..1]),
      plane_info_by_id(id, 'ingress_time').to_s[0..19],
      ( plane_info_by_id(id, 'landing_time') - Time.now ).to_i.to_s
    ]
  end

  def check_for_simulator
    return ( `pgrep -f simulator.rb`.split("\n").length > 0 ) ? "ON" : "OFF"
  end

  def server_time
    Time.now.to_s[0..18]
  end

  def dashboard_metrics
    [ count_planes_in_flight,
      count_planes_landed - 1, # Subtract the test flight
      count_planes_adjusted,
      count_planes_diverted,
      count_errors,
      check_for_simulator,
      server_time
    ]
  end
end
