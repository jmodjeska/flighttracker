require 'htmlbeautifier'
require 'nokogiri'
require 'controllers/atc'
require 'controllers/tracker'

module Helpers

  LABELS = {
    'descent'        => 'btn-primary',
    'final_approach' => 'btn-primary',
    'diverted'       => 'btn-warning',
    'error'          => 'btn-danger',
    'landed'         => 'btn-success',
    'test'           => 'btn-gray'
  }

  def format_html(page)
    HtmlBeautifier.beautify(Nokogiri::HTML(page).to_html)
  end

  def render_table_data(data_array)
    th = data_array[0].map { |th| "<th>#{th}</th>" }
    td = data_array[1].map do |tr|
      "<tr>" +
      tr.map.with_index do |td, i|
        if i == ( tr.length - 1 )
          "<td><button type=\"button\" class=\"btn #{LABELS[td]} " +
          "btn-xs\">#{td.gsub('_', ' ').split.map(&:capitalize).join(' ')}" +
          "</button></td>"
        else
        "<td>#{td}</td>"
        end
      end.join +
      "</tr>"
    end
    thead = "<thead><tr>#{th.join}</tr></thead>"
    tbody = "<tbody>#{td.join}</tbody>"
    return thead + tbody
  end

  def add_labels(array, arr_position)
    array[arr_position] = LABELS[array[arr_position]]
    return array
  end

  def instrument_config
    return [
      [ 'metric_inflight', 'primary', 'fa-plane', 'In Flight' ],
      [ 'metric_landed', 'green', 'fa-flag-checkered', 'Landings' ],
      [ 'metric_adjust', 'lightblue', 'fa-tachometer', 'Adjustments' ],
      [ 'metric_divert', 'yellow', 'fa-undo', 'Diversions' ],
      [ 'metric_errors', 'red', 'fa-warning', 'ATC Errors' ],
      [ 'sim_status', 'gray', 'fa-toggle-off', 'Inbound Sim' ]
    ]
  end
end
