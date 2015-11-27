$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'net/http'

module HTMLTemplates

  JQPLOTCDN    = 'https://cdnjs.cloudflare.com/ajax/libs/jqPlot/1.0.8/'
  BOOTSTRAPCDN = 'https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/'
  FONTCDN      = 'https://maxcdn.bootstrapcdn.com/font-awesome/4.4.0/'

  def html_header
    html = ''
    local_stylesheet = File.open('views/flighttracker.css', 'rb')

    javascripts = [
      'http://code.jquery.com/jquery-latest.min.js',
      JQPLOTCDN + 'jquery.jqplot.min.js',
      JQPLOTCDN + 'plugins/jqplot.bubbleRenderer.min.js',
      JQPLOTCDN + 'plugins/jqplot.highlighter.min.js',
      BOOTSTRAPCDN + 'js/bootstrap.min.js'
    ]

    styles = [
      JQPLOTCDN + 'jquery.jqplot.min.css',
      BOOTSTRAPCDN + 'css/bootstrap.min.css',
      FONTCDN + 'css/font-awesome.min.css',
      'http://getbootstrap.com/examples/cover/cover.css'
    ]

    # Bootstrap metas first
    html += '<meta charset="utf-8">' +
      '<meta name="viewport" content="width=device-width, initial-scale=1">'

    # Page title
    html += '<title>Flight Tracker</title>'

    # External javascripts
    javascripts.each do |js|
      html += "<script type=\"text/javascript\" src=\"#{js}\"></script>\n"
    end

    # External styles
    styles.each do |css|
      html += "<link rel=\"stylesheet\" type=\"text/css\" href=\"#{css}\">\n"
    end

    # Local style, favicon
    html += "<style type=\"text/css\">#{local_stylesheet.read}</style>"
    html += '<link rel="shortcut icon" href="http://j.modjeska.us/favicon.ico">'

    # Body
    html += '<div class="site-wrapper"><div class="site-wrapper-inner">' +
      '<div class="cover-container"><div class="clearfix"><div class="inner">' +
      '<h3 class="masthead-brand"><i class="fa fa-paper-plane-o"></i> ' +
      '<a href="https://github.com/jmodjeska/flighttracker">Flight Tracker' +
      '</h3><nav></nav></div></div><div class="inner cover">'
    return html
  end

  def html_footer
    html = '</div><div class="footer"><div class="inner">' +
      '<p id="time"></p></div></div></div></div></div>'
    return html
  end

  def not_found
    html = '<h1>Not found</h1>'
    return html
  end

  def fancy_webpage
    js = File.open('views/flighttracker.js', 'rb')
    html = '<h2 class="cover-heading" id="banner">All airborne flights ' +
      '<span id="flight_count"></span></h2><p></p>' +
      '<div id="chart" class="plot">Looking for airplanes ...<br><br>' +
      '<h1><i class="fa fa-cog fa-spin"></i></h1></div>' +
      "<script type=\"text/javascript\">#{js.read.to_s}</script>"
    return html
  end

  def get_tracker_array(tracker_json)
    tracker_array = JSON.parse(tracker_json)['aircrafts'].map do |flight|
      next if flight['x'].nil? || flight['x'] == 0
      [ flight['x'], flight['y'], 30, flight['flight'],
        get_airline(flight['flight']), flight['altitude'] ]
    end.compact
    tracker_array << [0, 0, 10, '', 'Final Approach Start Point', 800]
    tracker_array << [0, 20000, 10, '', 'Touchdown Point', 0]
    return tracker_array
  end

  def get_airline(flight_code)
    iata_code = flight_code[0..1]
    IO.foreach('../data/iata_codes.txt') do |line|
      return line[7..-1] if (line[/^#{iata_code}\b/])
    end
  end
end
