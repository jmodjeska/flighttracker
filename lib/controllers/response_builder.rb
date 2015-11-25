$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'models/queries'

module Builder
include Queries

  # JSON endpoints

  def tracker_json
    return "planes in flight"
    # Planes in flight
    # Landed in last 2 minutes
  end

  def entry_response_json
    return "accepted"
    # Accepted / diverted
    # Speed
  end

  # HTML components

  def fancy_webpage
    return "fancy webpage"
    # Header
    # Planes in flight as table
    # Landed in last 24 hours as table
    # Scaffolding for graph (though JS should probably call the json endpoint)
    # Refetch button AJAX
    # Footer
  end

  def not_found_html
    return "not found"
    # Simple 404
  end
end
