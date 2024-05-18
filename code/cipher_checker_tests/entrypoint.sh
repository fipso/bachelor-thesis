#!/bin/bash

set -x

function run_chromium {
  #Spawn fake X
  Xvfb :99 -ac -screen 0 640x480x8 -nolisten tcp &

  # Prepare chromium
  wget -O chromium.zip $CHROMIUM_URL
  unzip chromium.zip
  ./install_deps.sh ./chrome-linux/chrome

  # Run test chromium
  ./chrome-linux/chrome --no-sandbox --no-first-run --no-zygote --disable-gpu --disable-software-rasterizer --disable-dev-shm-usage https://ba-testing.unsafe.blazed.win:8443/check.html
}

cd /app

# Spawn chromium
run_chromium 2>&1 &

# Spawn check script
./check.sh
