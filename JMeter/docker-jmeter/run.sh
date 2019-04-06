#!/bin/bash
# File run.sh 

export timestamp=$(date +%Y%m%d_%H%M%S) && \
export volume_path=<where files are on host> && \
export jmeter_path=/mnt/jmeter && \
docker run \
  --volume “${volume_path}”:${jmeter_path} \
  jmeter \
  -n <any sequence of jmeter args> \
  -t ${jmeter_path}/<jmx_script> \
  -l ${jmeter_path}/tmp/result_${timestamp}.jtl \
  -j ${jmeter_path}/tmp/jmeter_${timestamp}.log 

