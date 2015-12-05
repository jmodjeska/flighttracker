$(document).ready(function(){

  function update_dashboard() {
    var metric_data = $.get('/realtime_metrics');

    metric_data.success(function(result) {
      $("#errorMessageRow").hide();

      var metrics = JSON.parse(result);
      var instruments = metrics[0];
      var inflight_table = metrics[1];
      var log_table = metrics[2];
      var graph_data = metrics[3];

      $("#metric_inflight").text(instruments[0]);
      $("#metric_landed").text(instruments[1]);
      $("#metric_adjust").text(instruments[2]);
      $("#metric_divert").text(instruments[3]);
      $("#metric_errors").text(instruments[4]);
      var sim_status = instruments[5];
      $("#sim_status").text(sim_status);
      if (sim_status == "ON") {
        $("#sim_status_icon").html('<i class="fa fa-toggle-on fa-5x"></i>');
      }
      else {
        $("#sim_status_icon").html('<i class="fa fa-toggle-off fa-5x"></i>');
      }
      $("#time").empty().append(instruments[6]);
      $("#inflight_table").empty().append(inflight_table);
      $("#log_table").empty().append(log_table);

      jQuery('#chart').html('');

      graph_data.forEach(function(graph_point) {
        graph_point[3] = '<i class="fa fa-plane plane-icon fa-2x fa-rotate-' +
          + graph_point[3] + '"></i><span class="plane-label">' + graph_point[4]
          + '</span>';
        graph_point.splice(4, 1);
      });

      console.log(graph_data);
      plot1 = $.jqplot('chart',[graph_data],{
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
            bubbleAlpha: 0,
            highlightAlpha: 0,
            autoscaleBubbles: false,
            escapeHtml: false
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
          formatString: 'x: %d, y: %d<br>' +
            '<div style="display:none;">%d</div>' +
            '<div style="text-align:center;"><b>%s</b></div>',
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
      var alt_array = [];
      $.each(graph_data, function(array) {
        if ( graph_data[array][2] != 5 ) {
          xzpair = [ graph_data[array][0], graph_data[array][4], graph_data[array][5] ];
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
    metric_data.error(function(jqXHR, textStatus, errorThrown) {
      $("#errorText").text('Connection error (' + textStatus + ": " + errorThrown + ').');
      $("#errorMessageRow").show();
    });
  }

  window.setInterval(update_dashboard, 5000);

  var version = $.get('/version');
  version.success(function(result) {
    var ver = result;
    $("#version").text(ver);
  });

  $('#chart').bind('jqplotDataClick',
    function (ev, seriesIndex, pointIndex, data) {
      show_modal(data[5]);
    }
  );

  $('#chart2').bind('jqplotDataClick',
    function (ev, seriesIndex, pointIndex, data) {
      show_modal(data[2]);
    }
  );

  function show_modal(id) {
    $('#flight_info_body_loading').show();
    $('#flight_modal').modal('show');
    var flight_details = $.get('/flight_details?id=' + id);
    flight_details.success(function(result) {
      var flight_detail_array = JSON.parse(result);
      $('#flight_info_0').text(flight_detail_array[0]);        // Flight Code
      $('#flight_info_1').addClass(flight_detail_array[1]);    // Button Style
      $('#flight_info_2').text(flight_detail_array[2]);        // Button Text
      $('#flight_info_3').attr("src", flight_detail_array[3]); // Image Src
      $('#flight_info_4').text(flight_detail_array[4]);        // Airline
      $('#flight_info_5').text(flight_detail_array[5]);        // Country
      $('#flight_info_6').text(flight_detail_array[6]);        // Ingress
      $('#flight_info_7').text(flight_detail_array[7]);        // TTL
      $('#flight_info_body_loading').hide();
      $('#flight_info_body').show();
      $('#flight_info_header').show();
    });
  }

  function reset_modal() {
    $('#flight_info_body').hide();
    $('#flight_info_header').hide();
  }

  function reposition() {
  // http://www.abeautifulsite.net/vertically-centering-bootstrap-modals
    var modal = $(this),
      dialog = modal.find('.modal-dialog');
      modal.css('display', 'block');
      dialog.css("margin-top", Math.max(0, ($(window).height() - dialog.height()) / 2));
  }
  $('.modal').on('show.bs.modal', reposition);
  $('.modal').on('hide.bs.modal', reset_modal);

  $(window).on('resize', function() {
        $('.modal:visible').each(reposition);
  });

});
