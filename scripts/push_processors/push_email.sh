#!/bin/bash
#
# Purpose: Send email to external address with each output image attached as a separate
#          email. Subject line and body contain details. 
#
# Instructions:
#  1. Edit ~/.msmtprc to configure your email service.
#  2. Setup handling services (for example IFTTT.COM to forward images to Facebook page)
# 
# Input parameters:
#   1. Email address
#   2. Attachment (image)
#   3. Email Subject

# import common lib and settings
. "$HOME/.noaa-v2.conf"
. "$NOAA_HOME/scripts/common.sh"

# input params
EMAIL_ADDRESS=$1
ATTACHMENT=$2
SUBJECT=$3

# check that the file exists and is accessible
if [ -f "${ATTACHMENT}" ]; then 
  log "Emailing to address $EMAIL_ADDRESS" "INFO"
  mpack -s "${SUBJECT}" ${ATTACHMENT} ${EMAIL_ADDRESS}
else
  log "Could not find or access image/attachment - not sending an email" "ERROR"
fi
