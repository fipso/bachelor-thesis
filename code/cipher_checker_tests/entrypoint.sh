#!/bin/bash

function start_timeout {
  sleep 45
  # Kill all children after timeout expires
  pkill -9 -P $$
}

function run_chromium {
  # Spawn fake X
  Xvfb :99 -ac -screen 0 640x480x8 -nolisten tcp &

  # Prepare chromium
  wget -O chromium.zip $CHROMIUM_URL
  unzip chromium.zip

  # The dependencies should already included in the base docker container
  # This is just a fallback in case new dependencies are added
  ./install_deps.sh ./chrome-linux/chrome

  # Start timeout before running chromium
  start_timeout &

  # Run test chromium
  ./chrome-linux/chrome\
    --no-sandbox\
    --disable-setuid-sandbox\
    --no-first-run\
    --no-zygote\
    --disable-gpu\
    --disable-software-rasterizer\
    --disable-dev-shm-usage\
      https://ba-testing.unsafe.blazed.win:8443/check.html
}

cd /app

# Spawn chromium
run_chromium 2>&1 &

# Spawn check script
./check.sh
