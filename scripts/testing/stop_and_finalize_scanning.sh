#!/bin/bash
#
# Purpose: Stop scanning and create a heatmap from a csv generated by rtl_power.
#
# Inputs:
#    1. GZip file used to store CSV scan data that should be used to generate waterfall image
#
# Example:
#   ./stop_and_finalize_scanning.sh my_scan.csv.gz

[ $# -lt 1 ] && echo "usage: $0 inputfile" && exit -1

scriptpath=$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )

# check if existing stop script is already running and
# terminate that instance of it
stopPid=$(ps -Alef | grep stop_and_finalize_scanning | grep sleep | awk '{print $4}')
if [ ! -z "${stopPid}" ]; then
  kill $stopPid
fi

killall rtl_power
$scriptpath/generate_waterfall.sh $1
rm $1
