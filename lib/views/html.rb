$LOAD_PATH.unshift(File.dirname(__FILE__))

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

    # Local style
    html += "<style type=\"text/css\">#{local_stylesheet.read}</style>"

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
      [flight["x"], flight["y"], 20, flight["flight"]]
    end.compact
    html = ''

    if tracker_array.empty?
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
end
