$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'active_support/all'
require 'active_record'
require 'controllers/calculations'
require 'models/models'

module Queries
include Models
include Calculations

  def prime_database
    if Flight.first.nil?
      ingress_time = Time.now - 5000
      Flight.create( {
      :ingress_time        => ingress_time,
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
      :ingress_time        => ingress_time,
      :final_approach_time => ingress_time + time_ingress_to_fa,
      :landing_time        => ingress_time + time_ingress_to_fa +
        time_fa_to_land,
      :flight_code         => flight_code
    } )
  end

  def find_all_planes_in_flight
    Flight.where( 'landing_time >?', Time.now ).as_json
  end

  def time_last_plane_at_ingress
    Flight.where( :action => 'accepted' ).first.ingress_time
  end

  def speed_last_plane
    Flight.where( :action => 'accepted' ).first.descent_speed
  end

  def time_last_plane_at_fa
    Flight.where( :action => 'accepted' ).first.final_approach_time
  end

  def update_atc_decision(value, decision)
    Flight.first.update( value => decision )
  end
end
