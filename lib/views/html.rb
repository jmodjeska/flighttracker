$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'net/http'

module HTMLTemplates

  def html_header
    html = ''
    jqplotcdn = 'https://cdnjs.cloudflare.com/ajax/libs/jqPlot/1.0.8/'
    bootstrapcdn = 'https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/'
    fontawesomecdn = 'https://maxcdn.bootstrapcdn.com/font-awesome/4.4.0/'
    local_stylesheet = File.open("views/flighttracker.css", "rb")

    javascripts = [
      'http://code.jquery.com/jquery-latest.min.js',
      jqplotcdn + 'jquery.jqplot.min.js',
      jqplotcdn + 'plugins/jqplot.bubbleRenderer.min.js',
      jqplotcdn + 'plugins/jqplot.highlighter.min.js',
      bootstrapcdn + 'js/bootstrap.min.js'
    ]

    styles = [
      jqplotcdn + 'jquery.jqplot.min.css',
      bootstrapcdn + 'css/bootstrap.min.css',
      fontawesomecdn + 'css/font-awesome.min.css',
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
      '<div class="cover-container"><div class="clearfix">' +
      '<div class="inner"><h3 class="masthead-brand">' +
      '<i class="fa fa-paper-plane-o"></i> ' +
      '<a href="https://github.com/jmodjeska/flighttracker">Flight Tracker' +
      '</h3><nav></nav></div></div><div class="inner cover">'

    return html
  end

  def html_footer
    html = '</div><div class="footer"><div class="inner">' +
      '<p>' + Time.now.to_s + '</p></div></div></div></div></div>'

    return html
  end

  def not_found
    html = '<h1>Not found</h1>'
    return html
  end

  def fancy_webpage(tracker_json)
    tracker_array = JSON.parse(tracker_json)["aircrafts"].map do |flight|
      next if flight["x"].nil? || flight["x"] == 0
      [ flight["x"], flight["y"], 30, flight["flight"],
        get_airline(flight["flight"]), flight["altitude"] ]
    end.compact
    tracker_array << [0, 0, 10, '', 'Final Approach Start Point', 800]
    tracker_array << [0, 20000, 10, '', 'Touchdown Point', 0]

    html = ''

    if tracker_array.empty? || tracker_array.length == 2
      return '<h2 class="cover-heading">No planes in flight in the timeframe ' +
        'provided.</h2><p class="help">Try a longer timeframe with the ' +
        '<a href="?timeframe=10000">timeframe</a> param, or send in some ' +
        'more airplanes!</p>'
    else
      html += '<h2 class="cover-heading">All airborne flights</h2><p></p>'
    end

    html += '<div id="chart" class="plot"></div>'
    javascript = %Q(
      <script type="text/javascript">
        $(document).ready(function(){
          var arr = #{tracker_array};
          plot1 = $.jqplot('chart',[arr],{
            title: '',
            grid:{
              background: 'transparent'
            },
            seriesDefaults:{
              renderer: $.jqplot.BubbleRenderer,
              rendererOptions: {
                bubbleAlpha: 0.8,
                highlightAlpha: 1.0,
                autoscaleBubbles: false
              },
              shadow: true,
              shadowAlpha: 0.05
            },
            highlighter: {
              tooltipContentEditor: function (str, seriesIndex, pointIndex) {
                return str + "<br><br>";
              },
              show: true,
              showTooltip: true,
              tooltipFade: true,
              sizeAdjust: 25,
              formatString: 'x: %d, y: %d<br>' +
                '<span style="display:none;">%s</span>' +
                '<b style="font-size: 20px; color: #4cae4c">%s</b><br>%s<br>' +
                '<b>Altitude: %d m</b>',
              tooltipLocation: 'n',
              useAxesFormatters: false
            },
            axes:{
              xaxis: {
                min: -4000,
                max: 20000
              },
              yaxis: {
                min: -65000,
                max: 65000
              }
            }
          });
        });
      </script>
    )
    return html + javascript
  end

  def get_airline(flight_code)
    iata_code = flight_code[0..1]
    IO.foreach('../data/iata_codes.txt') do |line|
      return line[7..-1] if (line[/^#{iata_code}\b/])
    end
  end
end
