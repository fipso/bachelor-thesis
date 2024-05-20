#!/bin/bash

mkdir -p ./logs/

# Cleanup from previous runs
killall openssl
rm -rf ./logs/*

# List of default ciphers supported by openssl s_server
ciphers=$(cat <<-END
TLSv1.3    :TLS_AES_128_GCM_SHA256
TLSv1.3    :TLS_AES_256_GCM_SHA384
TLSv1.3    :TLS_AES_128_CCM_SHA256
TLSv1.3    :TLS_CHACHA20_POLY1305_SHA256
TLSv1.2    :ECDHE-ECDSA-AES256-GCM-SHA384
TLSv1.2    :ECDHE-RSA-AES256-GCM-SHA384
TLSv1.2    :ECDHE-ECDSA-CHACHA20-POLY1305
TLSv1.2    :ECDHE-RSA-CHACHA20-POLY1305
TLSv1.2    :ECDHE-ECDSA-AES256-CCM
TLSv1.2    :ECDHE-ECDSA-AES128-GCM-SHA256
TLSv1.2    :ECDHE-RSA-AES128-GCM-SHA256
TLSv1.2    :ECDHE-ECDSA-AES128-CCM
TLSv1.2    :ECDHE-ECDSA-AES128-SHA256
TLSv1.2    :ECDHE-RSA-AES128-SHA256
TLSv1.2    :AES256-GCM-SHA384
TLSv1.2    :AES256-CCM
TLSv1.2    :AES128-GCM-SHA256
TLSv1.2    :AES128-CCM
TLSv1.2    :AES256-SHA256
TLSv1.2    :AES128-SHA256
TLSv1.2    :DHE-RSA-AES256-GCM-SHA384
TLSv1.2    :DHE-RSA-CHACHA20-POLY1305
TLSv1.2    :DHE-RSA-AES256-CCM
TLSv1.2    :DHE-RSA-AES128-GCM-SHA256
TLSv1.2    :DHE-RSA-AES128-CCM
TLSv1.2    :DHE-RSA-AES256-SHA256
TLSv1.2    :DHE-RSA-AES128-SHA256
TLSv1.2    :PSK-AES256-GCM-SHA384
TLSv1.2    :PSK-CHACHA20-POLY1305
TLSv1.2    :PSK-AES128-CCM
TLSv1.2    :PSK-AES256-CCM
TLSv1.2    :PSK-AES128-GCM-SHA256
TLSv1.2    :DHE-PSK-AES256-GCM-SHA384 
TLSv1.2    :DHE-PSK-AES256-CCM        
TLSv1.2    :DHE-PSK-AES128-CCM
TLSv1.2    :ECDHE-PSK-CHACHA20-POLY1305 
TLSv1.2    :RSA-PSK-AES256-GCM-SHA384 
TLSv1.2    :RSA-PSK-AES128-GCM-SHA256 
TLSv1.2    :DHE-PSK-CHACHA20-POLY1305
TLSv1.2    :DHE-PSK-AES128-GCM-SHA256
TLSv1.2    :RSA-PSK-CHACHA20-POLY1305
END
)

# Old TLSv1.0 ciphers; Does not work after chrome 40
# TLSv1.0    :ECDHE-ECDSA-AES256-SHA
# TLSv1.0    :ECDHE-RSA-AES256-SHA
# TLSv1.0    :ECDHE-ECDSA-AES128-SHA
# TLSv1.0    :ECDHE-RSA-AES128-SHA
# TLSv1.0    :PSK-AES128-CBC-SHA256
# TLSv1.0    :DHE-PSK-AES128-CBC-SHA256
# TLSv1.0    :ECDHE-PSK-AES128-CBC-SHA256
# TLSv1.0    :RSA-PSK-AES128-CBC-SHA256
# TLSv1.0    :ECDHE-PSK-AES256-CBC-SHA
# TLSv1.0    :ECDHE-PSK-AES128-CBC-SHA

# Spawn static https server to serve check.html and api
www_port=8443
openssl s_server -key key.pem -cert cert.pem -accept $www_port -WWW &

# Spawn openssl s_server with -brief flag to collect browser user agent and supported ciphers
www_meta_port=8444
sleep 999999 | openssl s_server -key key.pem -cert cert.pem -accept $www_meta_port -brief &> ./browser_meta.txt &

# Start of test s_server port range
port=8000

while IFS= read -r line; do
  cs=$(echo $line | sed 's/.*://')
  echo "Spawning server with cipher: $cs"

  cipher_param=""

  # Detect if its TLSv1.3 or lower
  is_tls13=$(echo $line | grep -c "TLSv1.3")

  # Use the correct openssl command based on TLS version
  if [ $is_tls13 -eq 1 ]; then
    cipher_param="-ciphersuites $cs -no_tls1_2 -no_tls1_1 -no_tls1 -no_ssl3"
  else
    cipher_param="-cipher $cs -no_tls1_3"
  fi

  # Spawn check server and redirect log to file
  openssl s_server -key key.pem -cert cert.pem -accept $port -www $cipher_param -serverpref -debug > "logs/$port-$cs.txt" 2>&1 &

  port=$((port+1))
done <<< "$ciphers"

# Check all log files for errors and print overview of server status
while true; do
  result_json="{\"ciphers\":["

  echo -e "  \nServer status:\n"
  status_array=()
  for file in ./logs/*; do
    filename=$(basename $file)

    # Extract cipher name: format is PORT-CIPHER-NAME.txt
    cipherName="${filename#*-}"
    cipherName="${cipherName%.txt}"
    status=""

    if grep -q "error" $file; then
      status="error"

      # Pad the string to ensure alignment
      padded_filename=$(printf "%-50s" "\033[31m$filename\033[0m")
      status_array+=("$padded_filename")
    elif [ $(wc -l < $file) -le 2 ]; then
      status="no connection"

      # if there are less or equal than 2 lines in the log color it orange
      padded_filename=$(printf "%-50s" "\033[33m$filename\033[0m")
      status_array+=("$padded_filename")
    else
      status="ok"

      padded_filename=$(printf "%-50s" "\033[32m$filename\033[0m")
      status_array+=("$padded_filename")
    fi

    cmd=$(ps x | grep -- "-cipher $cipherName " | grep -v grep)
    result_json+="{\"cipher\":\"$cipherName\",\"status\":\"$status\",\"logs\":$(jq -R -s '.' < $file),\"command\":\"$cmd\"},"
  done

  # Print array elements and pipe to column for multi-column display
  printf '%b\n' "${status_array[@]}" | column

  # Remove trailing comma
  result_json=$(echo $result_json | sed 's/,$//')
  # Add browser meta data and end json
  result_json+="],\"browser\":$(jq -R -s '.' < ./browser_meta.txt)}"

  # If browser meta has been written, stop
  if [ $(wc -l <./browser_meta.txt) -ge 2 ]; then
    echo -e "\nBrowser meta data collected\n"
    echo -e "\nExiting...\n"
    echo -e "\nResult JSON:\n"
    echo "$result_json" | jq
    echo "$result_json" > ./result.json
    break
  fi

  sleep 1
done
