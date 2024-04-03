#!/bin/bash

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
TLSv1.2    :PSK-AES128-GCM-SHA25
TLSv1.2    :DHE-PSK-AES256-GCM-SHA384 
TLSv1.2    :DHE-PSK-AES256-CCM        
TLSv1.2    :DHE-PSK-AES128-CCM
TLSv1.2    :ECDHE-PSK-CHACHA20-POLY1305 
TLSv1.2    :RSA-PSK-AES256-GCM-SHA384 
TLSv1.2    :RSA-PSK-AES128-GCM-SHA256 
TLSv1.2    :DHE-PSK-CHACHA20-POLY1305
TLSv1.2    :DHE-PSK-AES128-GCM-SHA256
TLSv1.2    :RSA-PSK-CHACHA20-POLY1305
TLSv1.0    :ECDHE-ECDSA-AES256-SHA
TLSv1.0    :ECDHE-RSA-AES256-SHA
TLSv1.0    :ECDHE-ECDSA-AES128-SHA
TLSv1.0    :ECDHE-RSA-AES128-SHA
TLSv1.0    :PSK-AES128-CBC-SHA256
TLSv1.0    :DHE-PSK-AES128-CBC-SHA256
TLSv1.0    :ECDHE-PSK-AES128-CBC-SHA256
TLSv1.0    :RSA-PSK-AES128-CBC-SHA256
TLSv1.0    :ECDHE-PSK-AES256-CBC-SHA
TLSv1.0    :ECDHE-PSK-AES128-CBC-SHA
SSLv3      :AES256-SHA
SSLv3      :AES128-SHA
SSLv3      :DHE-RSA-AES128-SHA
SSLv3      :PSK-AES256-CBC-SHA
SSLv3      :PSK-AES128-CBC-SHA
SSLv3      :DHE-PSK-AES256-CBC-SHA
SSLv3      :DHE-PSK-AES128-CBC-SHA
SSLv3      :RSA-PSK-AES256-CBC-SHA
SSLv3      :RSA-PSK-AES128-CBC-SHA
SSLv3      :DHE-RSA-AES256-SHA
END
)

# Start of test s_server port range
port=4000

while IFS= read -r line; do
  cs=$(echo $line | sed 's/.*://')
  echo "Spawning server with cipher: $cs"

  cipher_param=""

  # Detect if its TLSv1.3 or lower
  is_tls13=$(echo $line | grep -c "TLSv1.3")

  # Use the correct openssl command based on TLS version
  if [ $is_tls13 -eq 1 ]; then
    cipher_param="-ciphersuites $cs"
  else
    cipher_param="-cipher $cs"
  fi

  # Redirect log to file
  openssl s_server -key key.pem -cert cert.pem -accept $port -www $cipher_param >> "logs/$port-$cs.txt" 2>&1 &

  port=$((port+1))
done <<< "$ciphers"

# Check all log files for errors and print overview of server status
while true; do
  echo -e "  \nServer status:\n"
  status_array=()
  for file in ./logs/*; do
    filename=$(basename $file)
    if grep -q "error" $file; then
      # Pad the string to ensure alignment
      padded_filename=$(printf "%-50s" "\033[31m$filename\033[0m")
      status_array+=("$padded_filename")
    else
      padded_filename=$(printf "%-50s" "\033[32m$filename\033[0m")
      status_array+=("$padded_filename")
    fi
  done

  # Print array elements and pipe to column for multi-column display
  printf '%b\n' "${status_array[@]}" | column
  sleep 1
done
