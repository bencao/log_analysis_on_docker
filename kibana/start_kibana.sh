#!/bin/bash

env

cat << EOF > /opt/kibana/config.js
define(['settings'],
function (Settings) {
  return new Settings({
    elasticsearch : "http://"+window.location.hostname+":9200",
    default_route : '/dashboard/file/default.json',
    kibana_index  : "kibana-int",
    panel_names   : [
      'histogram',
      'map',
      'goal',
      'table',
      'filtering',
      'timepicker',
      'text',
      'hits',
      'column',
      'trends',
      'bettermap',
      'query',
      'terms',
      'stats',
      'sparklines'
    ]
  });
});
EOF

cd /opt/kibana && python -m SimpleHTTPServer
