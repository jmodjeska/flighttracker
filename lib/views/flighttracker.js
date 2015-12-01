$(document).ready(function(){

  function update_dashboard() {
    var graph_data = $.get('/realtime_tracking_info');
    var metric_data = $.get('/realtime_metric_info');
    var inflight_data = $.get('/realtime_inflight_info');
    var log_data = $.get('/realtime_log_info');
    var server_time = $.get('/server_time');

    server_time.success(function(result) {
      // console.log(result);
      var server_time = result;
      $("#time").empty().append(server_time);
    });

    inflight_data.success(function(result) {
      // console.log(result);
      var inflight_table_data = result;
      $("#inflight_table").empty().append(inflight_table_data);
    });

    log_data.success(function(result) {
      // console.log(result);
      var log_table_data = result;
      $("#log_table").empty().append(log_table_data);
    });

    metric_data.success(function(result) {
      // console.log(result);
      var metrics = JSON.parse(result);
      $("#metric_inflight").text(metrics[0]);
      $("#metric_landed").text(metrics[1]);
      $("#metric_adjust").text(metrics[2]);
      $("#metric_divert").text(metrics[3]);
      $("#metric_errors").text(metrics[4]);
    });

    var sim = $.get('/sim_status');
    sim.success(function(result) {
      var sim_status = result;
      $("#sim_status").text(sim_status);
      if (sim_status == "ON") {
          $("#sim_status_icon").html('<i class="fa fa-toggle-on fa-5x"></i>');
      }
      else {
          $("#sim_status_icon").html('<i class="fa fa-toggle-off fa-5x"></i>');
      }
    });

    graph_data.success(function(result) {
      // console.log(result);
       $("#errorMessageRow").hide();
       jQuery('#chart').html('');
      plot1 = $.jqplot('chart',[JSON.parse(result)],{
        title: '',
        grid:{
          borderColor: '#eee',
          shadow: false,
          background: 'transparent'
        },
        seriesColors: [ "#337ab7" ],
        seriesDefaults:{
          renderer: $.jqplot.BubbleRenderer,
          rendererOptions: {
            bubbleAlpha: 0.9,
            highlightAlpha: 1.0,
            autoscaleBubbles: false
          },
          shadow: false,
          shadowAlpha: 0
        },
        highlighter: {
          tooltipContentEditor: function (str, seriesIndex, pointIndex) {
            return str;
          },
          show: true,
          showTooltip: true,
          tooltipFade: true,
          sizeAdjust: 20,
          formatString: 'x: %d, y: %d',
          tooltipLocation: 'n',
          useAxesFormatters: false
        },
        axes:{
          xaxis: {
            min: -5000,
            max: 21000,
            ticks: [[-5000,"-5000"], [0,"0"], [5000,"5000"], [10000, "10000"], [15000,"15000"], [20000,"20000"]],
          },
          yaxis: {
            min: -65000,
            max: 65000
          }
        }
      });
      jQuery('#chart2').html('');
      var json_data = JSON.parse(result);
      var alt_array = [];
      $.each(json_data, function(array) {
        if ( json_data[array][2] != 5 ) {
          xzpair = [ json_data[array][0], json_data[array][4] ];
          alt_array.push(xzpair);
        }
      });
      if ( alt_array.length < 1 ) {
        $("#chart2").html('<p style="font-size: 14px;">No planes in flight.</p>')
      }
      else {
          plot2 = $.jqplot('chart2', [alt_array],{
            title:'',
            grid:{
              borderColor: '#eee',
              shadow: false,
              background: 'transparent'
            },
            axes:{
              xaxis: {
                min: -5000,
                max: 20000,
                ticks: [[-5000,""], [0,"Final Approach"], [16000,"Ingress"], [20000, ""]],
                tickOptions: {
                  showGridline: false
                },
              },
              yaxis: {
                min: 0,
                max: 12000
              }
            },
            seriesDefaults: {
              rendererOptions: {
                smooth: true
              }
            },
            series:[
              {
                showLine:false,
                markerOptions: { size: 10, style: "filledCircle" }
              }
            ]
          });
      }
    });
    graph_data.error(function(jqXHR, textStatus, errorThrown) {
      $("#errorText").text('Connection error (' + textStatus + ": " + errorThrown + ').');
      $("#errorMessageRow").show();
    });
  }

  window.setInterval(update_dashboard, 4000);

  var version = $.get('/version');
  version.success(function(result) {
    var ver = result;
    $("#version").text(ver);
  });
});
