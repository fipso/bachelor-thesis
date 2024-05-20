#!/usr/bin/env python3

import json
import os
import re
import sys


if len(sys.argv) < 2:
    print("Usage: python3 parse_results.py <path>")
    sys.exit(1)

path = sys.argv[1]

results = []
if os.path.isdir(path):
    # Read each json in the results folder
    for file in os.listdir(path):
        if not file.endswith('.json'):
            continue

        with open(os.path.join(path, file)) as f:
            results.append(json.load(f))
if os.path.isfile(path):
    with open (path, "r") as f:
        results.append(json.load(f))

#parsed = {}
for result in results:
    browserLines = result['browser'].split('\n')
    ua = ''
    clientCiphers = []
    for line in browserLines:
        if 'User-Agent' in line:
            ua = line
        if 'Client cipher list' in line:
            clientCiphers = line.replace("Client cipher list: ", "").split(":")

    # Print chromium User-Agent and supported client ciphers
    print(ua)
    print("Client ciphers:")
    for clientCipher in clientCiphers:
        print("  ", clientCipher)

    # Check if client ciphers could be verified
    ciphers = result['ciphers']
    checkedCiphers = []
    for clientCipher in clientCiphers:
        for cipher in ciphers:
            if cipher['cipher'] == clientCipher:
                checkedCiphers.append(clientCipher)
                if cipher['status'] == "ok":
                    print("\033[0;32mCheck Passed with Cipher:", clientCipher, "\033[0m")
                    break
                else:
                    print("\033[0;31mCheck Failed with Cipher:", clientCipher, "\033[0m")
                   
                    if cipher['status'] == 'no connection':
                        print("  \033[1;29;40mNever connected to check server\033[0m")
                        break

                    # Print command of failed check
                    print("    Command:", cipher['command'], "\n")

                    # Print logs of failed check
                    found = False
                    for line in cipher['logs'].split('\n'):
                        if 'error' in line:
                                found = True
                                print("  ", line, "\033[0m")

                    if not found:
                        print(cipher['logs'])

                    break


    # Print ciphers that were not checked
    for clientCipher in clientCiphers:
        if clientCipher not in checkedCiphers:
            print("\033[1;29;40mNot checked cipher:", cipher['cipher'], "\033[0m")
