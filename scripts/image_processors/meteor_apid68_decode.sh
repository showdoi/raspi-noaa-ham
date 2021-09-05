#!/bin/bash
#
# Purpose: Decode a METEOR-M 2 APID 68 image.
#
# Input parameters:
#   1. Input .dec file
#   2. Output filename for bmp image
#
# Example:
#   ./meteor_apid68_decode.sh /path/to/input.dec /path/to/output.bmp

# import common lib and settings
. "$HOME/.noaa-v2.conf"
. "$NOAA_HOME/scripts/common.sh"

# input params
INPUT_DEC=$1
OUTPUT_BMP=$2

# produce the output image
$MEDET_ARM "${INPUT_DEC}" "${OUTPUT_BMP}" -r 68 -g 68 -b 68 -d
