#!/bin/bash

env

/opt/elasticsearch/bin/elasticsearch -f -Xmx12000m -Xms4000m -Des.max-open-files=true
