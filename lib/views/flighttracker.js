$(document).ready(function(){

  function update_graph() {
    var graph_data = $.get('/realtime_tracking_info');

    graph_data.success(function(result) {
      console.log(result);
      $("#flight_count").text('(' + (JSON.parse(result).length - 2) + ')')
      $("#time").text(timeStamp())
      jQuery('#chart').html('');
      plot1 = $.jqplot('chart',[JSON.parse(result)],{
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

    graph_data.error(function(jqXHR, textStatus, errorThrown) {
      $("#banner").text(textStatus + ": " + errorThrown);
    });

  }

  function timeStamp() {
  // https://gist.github.com/hurjas/2660489
    var now = new Date();
    var date = [ now.getFullYear(), now.getMonth() + 1, now.getDate() ];
    var time = [ now.getHours(), now.getMinutes(), now.getSeconds() ];
    var suffix = ( time[0] < 12 ) ? "AM" : "PM";
    time[0] = ( time[0] < 12 ) ? time[0] : time[0] - 12;
    time[0] = time[0] || 12;
    for ( var i = 1; i < 3; i++ ) {
      if ( time[i] < 10 ) {
        time[i] = "0" + time[i];
      }
    }
    return date.join("-") + " " + time.join(":") + " " + suffix;
  }

  window.setInterval(update_graph, 2000);

});
