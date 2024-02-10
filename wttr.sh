#!/bin/bash

# The script params
API_URL="$1"
TIMEOUT=$2
CACHE_PATH="$3"

########################## GLobal consts
REFRESH_RATE=$TIMEOUT
CACHE_DIR="$(dirname $CACHE_PATH)"

######### The Pre-request writes
[ -e "$CACHE_DIR" ] || mkdir "$CACHE_DIR"

function update-cache() {
  forecast=$(curl -fGsS --compressed -X GET "https://wttr.in/$API_URL" 2>&1)
  echo "$forecast" > "$CACHE_PATH"

  clear
  echo "$forecast"
}

function redraw-from-cache() {
  clear
  cat "$CACHE_PATH"
}


function is_cahe_timeout() {
  [ ! -e "$CACHE_PATH" ] && {
    return 0
  }

  cache_time=$(date -r "$CACHE_PATH" "+%s")
  now=$(date "+%s")
  cache_duration=$(expr $now - $cache_time)

  [ $cache_duration -gt $TIMEOUT ]
}

#### The Logic
[ -e "$CACHE_PATH" ] && ! $(is_cahe_timeout) && redraw-from-cache

while true; do
  is_cahe_timeout && {
    update-cache
    redraw-from-cache
  }

  sleep $REFRESH_RATE

  cache_time=$(date -r "$CACHE_PATH" "+%s")
done
