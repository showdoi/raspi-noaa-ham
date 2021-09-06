#!/bin/bash
#
# Purpose: Record Meteor-M audio via gnuradio to a bitstream file.
#
# 输入：
# 1. capture_time: 长度捕获的时间（以秒为单位）
# 2. out_s_file: 输出比特流文件的全限定文件名，包括“.s”扩展名
#
# Example (record meteor audio for 15 seconds, output to /srv/audio/meteor/METEORM2.s):
#   ./meteor_record_gnuradio.sh 15 /srv/audio/meteor/METEORM2.s

# import common lib and settings
. "$HOME/.noaa-v2.conf"
. "$NOAA_HOME/scripts/common.sh"

# input params
CAPTURE_TIME=$1
OUT_FILE=$2

# check that filename extension is bitstream (only type supported currently)
if [ ${OUT_FILE: -2} != ".s" ]; then
  log "Output file must end in .s extension." "ERROR"
  exit 1
fi

timeout "${CAPTURE_TIME}" "$NOAA_HOME/scripts/audio_processors/rtlsdr_m2_lrpt_rx.py" "${OUT_FILE}" "${GAIN}" "${FREQ_OFFSET}" >> $NOAA_LOG 2>&1
