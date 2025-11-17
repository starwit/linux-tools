#!/bin/bash

sudo turbostat --quiet --interval 1 --show Avg_MHz,PkgTmp,PkgWatt,SysWatt --Summary | \
while IFS= read -r line; do
    printf "%s;%s\n" "$(date --iso-8601=seconds)" "$(echo $line | sed -E 's/[[:space:]]+/;/g')"
done | tee -a turbostat_log_$(date --iso-8601=seconds).csv