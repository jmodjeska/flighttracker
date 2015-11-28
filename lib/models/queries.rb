$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'active_support/all'
require 'active_record'
require 'controllers/calculations'
require 'models/models'

module Queries
include Models
include Calculations

  CONS = YAML::load_file('../config/constants.yml')

  def prime_database
    if Flight.first.nil?
      ingress_time = Time.now - 5000
      Flight.create( {
        :ingress_time        => ingress_time,
        :ingress_altitude    => CONS['ingress_alt'],
        :final_approach_time => ingress_time + 510,
        :landing_time        => ingress_time + 510 + 200,
        :flight_code         => 'XX1234',
        :descent_speed       => 128,
        :action              => 'accepted'
      } )
    end
  end

  def record_flight_entry(flight_code, ingress_time)
    Flight.create( {
      :ingress_time => ingress_time,
      :flight_code  => flight_code
    } )
  end

  def recent_planes(seconds_ago)
    Flight.where( 'ingress_time > ?', Time.now - seconds_ago ).as_json
  end

  def airborne_planes
    Flight.where( 'landing_time > ?', Time.now ).as_json
  end

  def last_plane_info(column)
    Flight.where( :action => 'accepted' ).last.send(column)
  end

  def plane_info_by_id(id, column)
    Flight.where( :id => id ).first.send(column)
  end

  def update_flight_info(column, value)
    Flight.last.update( column => value )
  end

  def count_planes_in_flight
    Flight.where(
      ["action = ? and landing_time >= ?", 'accepted', Time.now] ).count
  end

  def count_planes_landed
    Flight.where(
      ["action = ? and landing_time < ?", 'accepted', Time.now] ).count
  end

  def count_planes_adjusted
    Flight.where(
      ["action = ? and descent_speed < ?", 'accepted', CONS['descent_max']] )
      .count
  end

  def count_planes_diverted
    Flight.where( :action => 'diverted' ).count
  end

  def count_errors
    Flight.where( "action = ? and ( landing_time is ? or
      final_approach_time is ? or ingress_altitude is ? or
      descent_speed is ? or ingress_altitude is ? )",
      'accepted', nil, nil, nil, nil, nil ).count
  end

  def log_table_data
    Flight.last(50)
  end

  def airborne_table_data
    Flight.where( ["action = ? and landing_time >= ?", 'accepted', Time.now] )
  end
end
