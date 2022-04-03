#!/bin/bash
#
# Purpose: High-level scheduling script - schedules all desired satellite
#          and orbital captures.
#
# Parameters:
#   -t: Update/re-download TLE files
#   -x: Wipe all existing future scheduled captures and start fresh
#
# Example:
#   ./schedule.sh -t -x

# import common lib and settings
. "$HOME/.noaa-v2.conf"
. "$NOAA_HOME/scripts/common.sh"

# 星历数据文件
WEATHER_TXT="${NOAA_HOME}/tmp/weather.txt"
AMATEUR_TXT="${NOAA_HOME}/tmp/amateur.txt"
TLE_OUTPUT="${NOAA_HOME}/tmp/orbit.tle"

# 检查星历是否需要更新
update_tle=0
wipe_existing=0
while getopts ":tx" opt; do
  case $opt in
    # update TLE files
    t)
      update_tle=1
      ;;
    x)
      wipe_existing=1
      ;;
  esac
done

if [ "${update_tle}" == "1" ]; then
  # wait for an IP to be assigned/DNS to be available so the TLE can be retrieved
  tle_addr="www.celestrak.com"
  max_iters_sec=60
  sleep_iter_seconds=5
  counter=0
  while [ -z "${ip_addr}" ] && [ $counter -lt $max_iters_sec ]; do
    ping -c 1 $tle_addr >/dev/null
    if [ $? -eq 0 ]; then
      break
    else
      log "Scheduler waiting for DNS resolution for TLE files..." "INFO"
      ((counter+=$sleep_iter_seconds))
      sleep $sleep_iter_seconds
    fi
  done

  if [ $counter -gt 60 ]; then
    log "Scheduler failed to resolve TLE endpoint in ${counter} seconds" "ERROR"
    exit
  else
    log "Scheduler resolved TLE endpoint in ${counter} seconds" "INFO"
  fi

  # 从 orbit 下载星历文件
  log "Downloading new TLE files from source" "INFO"
  wget -r "http://${tle_addr}/NORAD/elements/weather.txt" -O "${WEATHER_TXT}" >> $NOAA_LOG 2>&1
  wget -r "http://${tle_addr}/NORAD/elements/amateur.txt" -O "${AMATEUR_TXT}" >> $NOAA_LOG 2>&1

  # create tle files for scheduling
  #   note: it's really unfortunate but a directory structure any deeper than 'tmp' in the
  #   below results in a buffer overflow reported by the predict application, presumably
  #   because it cannot handle that level of sub-directory
  log "Clearing and re-creating TLE file with latest..." "INFO"
  echo -n "" > $TLE_OUTPUT
  grep "NOAA 15" $WEATHER_TXT -A 2 >> $TLE_OUTPUT
  grep "NOAA 18" $WEATHER_TXT -A 2 >> $TLE_OUTPUT
  grep "NOAA 19" $WEATHER_TXT -A 2 >> $TLE_OUTPUT
  grep "METEOR-M 2" $WEATHER_TXT -A 2 >> $TLE_OUTPUT
  #创建业余卫星计划
  #grep "iss" $AMATEUR_TXT -A 2 >> $TLE_OUTPUT
elif [ ! -f $WEATHER_TXT ] || [ ! -f $AMATEUR_TXT ] || [ ! -f $TLE_OUTPUT ]; then
  log "TLE update not specified '-t' but no TLE files present - please re-run with '-t'" "INFO"
  exit 1
else
  log "Not updating local copies of TLE files from source" "INFO"
fi

# section to remove all existing scheduled jobs/captures and clear
# all future database captures, making room for a brand new schedule
atq_date=""
if [ "${wipe_existing}" == "1" ]; then
  # remove 'at' jobs to make way for new jobs
  log "Clearing existing scheduled 'at' capture jobs..." "INFO"
  for i in $(atq | awk '{print $1}'); do
    atrm "$i"
  done

  # remove database passes for remainder of day
  cur_ms=$(date +"%s")
  log "Clearing existing passes specified in the database for remainder of the captures..." "INFO"
  $SQLITE3 $DB_FILE "DELETE FROM predict_passes WHERE pass_start > $cur_ms;"
else
  log "Determining latest scheduled capture job date..." "INFO"
  atq_date=$(atq | sort -k 6n -k 3M -k 4n -k 5 -k 7 -k 1 | awk '{print $3 " " $4 ", " $6}' | tail -1)
fi

start_time_ms=$(date +"%s")
last_day=$(($DAYS_TO_SCHEDULE_PASSES - 1))
end_time_ms=$(date --date="+${last_day} days 23:59:59" +"%s")
if [ -z "${atq_date}" ]; then
  log "No passes currently scheduled - scheduling all passes starting now through ${end_time_ms} ms..." "INFO"
else
  # calculate current day of last passes and what should be the
  # latest day of scheduled passes - assume if we've scheduled into
  # any point of the last day, we're covering all passes already
  latest_scheduled_ms=$(date --date="${atq_date} 23:59:59" +"%s")
  future_schedule_ms=$(date --date="+${last_day} days 00:00:00" +"%s")

  if [ "${latest_scheduled_ms}" -ge "${future_schedule_ms}" ]; then
    log "All passes already scheduled to latest date - nothing to be done" "INFO"
    exit
  else
    start_time_ms=$(($latest_scheduled_ms + 60))
    log "订阅开始日期  ${start_time_ms} ms 至 ${end_time_ms} ms..." "INFO"
  fi
fi

# create schedules to call respective receive scripts
log "安排新的卫星接收任务..." "INFO"
if [ "$NOAA_15_SCHEDULE" == "true" ]; then
  log "拿捏 NOAA 15 气象卫星..." "INFO"
  $NOAA_HOME/scripts/schedule_captures.sh "NOAA 15" "receive_noaa.sh" $TLE_OUTPUT $start_time_ms $end_time_ms >> $NOAA_LOG 2>&1
fi
if [ "$NOAA_18_SCHEDULE" == "true" ]; then
  log "拿捏 NOAA 18 气象卫星..." "INFO"
  $NOAA_HOME/scripts/schedule_captures.sh "NOAA 18" "receive_noaa.sh" $TLE_OUTPUT $start_time_ms $end_time_ms >> $NOAA_LOG 2>&1
fi
if [ "$NOAA_19_SCHEDULE" == "true" ]; then
  log "拿捏 NOAA 19 气象卫星..." "INFO"
  $NOAA_HOME/scripts/schedule_captures.sh "NOAA 19" "receive_noaa.sh" $TLE_OUTPUT $start_time_ms $end_time_ms >> $NOAA_LOG 2>&1
fi
if [ "$METEOR_M2_SCHEDULE" == "true" ]; then
  log "拿捏 Meteor-M 2 气象卫星..." "INFO"
  $NOAA_HOME/scripts/schedule_captures.sh "METEOR-M 2" "receive_meteor.sh" $TLE_OUTPUT $start_time_ms $end_time_ms >> $NOAA_LOG 2>&1
fi
log "恭喜~把这些卫星数据拿捏,祝接收顺利~ 73~ --DE BI4JGM !" "INFO"

if [ "${ENABLE_EMAIL_SCHEDULE_PUSH}" == "true" ]; then
  # create annotation to send as subject for email
  annotation="Scheduled Passes | "
  if [ "${GROUND_STATION_LOCATION}" != "" ]; then
    annotation="${annotation}Ground Station: ${GROUND_STATION_LOCATION} | "
  fi
  annotation="${annotation}Timezone Offset: ${TZ_OFFSET}"

  log "Generating image of pass list schedule for email" "INFO"
  pass_image="${NOAA_HOME}/tmp/pass-list.jpg"

  # determine if https or http supported
  web_addr="http://localhost:${WEBPANEL_PORT}"
  if [ "$ENABLE_NON_TLS" == "false" ]; then
    # assume user has enabled TLS
    web_addr="https://localhost:${WEBPANEL_TLS_PORT}"
  fi
  $WKHTMLTOIMG --format jpg --quality 100 $web_addr "${pass_image}" >> $NOAA_LOG 2>&1

  # crop the header (and optionally, satvis iframe, if enabled) out of pass list
  log "Removing header from pass list image" "INFO"
  $CONVERT "${pass_image}" -gravity North -chop 0x190 "${pass_image}" >> $NOAA_LOG 2>&1

  if [ "${ENABLE_SATVIS}" == "true" ]; then
    log "Removing Satvis iFrame from pass list image" "INFO"
    $CONVERT "${pass_image}" -gravity North -chop 0x510 "${pass_image}" >> $NOAA_LOG 2>&1
  fi

  log "Emailing pass list schedule to destination address" "INFO"
  ${PUSH_PROC_DIR}/push_email.sh "${EMAIL_PUSH_ADDRESS}" "${pass_image}" "${annotation}"
fi
