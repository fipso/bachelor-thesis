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

tableData = {}

for result in results:
    browserLines = result['browser'].split('\n')
    ua = ''
    clientCiphers = []
    for line in browserLines:
        if 'User-Agent' in line:
            ua = line
        if 'Client cipher list' in line:
            clientCiphers = line.replace("Client cipher list: ", "").split(":")

    # Get chrome version from User-Agent
    version = re.search(r"Chrome\/([^\s]+)", ua).group(1)
    print("Chrome Version:", version)

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

                tableData[(clientCipher, version)] = cipher['status']

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
            print("Not checked cipher:", clientCipher, "\033[0m")

# Generate HTML table
htmlTemplate = """
<html>
<head>
<style>
body {
    font-family: Arial, sans-serif;
}
th {
    word-wrap: break-word;
}
</style>
</head>
<body>
<table>
%TABLE%
</table>
</body>
</html>
"""

tableContent = ""

allCiphers = []
allChromeVersions = []
for key in tableData:
    if key[0] not in allCiphers:
        allCiphers.append(key[0])
    if key[1] not in allChromeVersions:
        allChromeVersions.append(key[1])

# Sort chrome version strings
allChromeVersions.sort(key=lambda x: list(map(int, x.split('.'))))

tableContent = "<tr><th></th>"
for cipher in allCiphers:
    tableContent += f"<th style=\"max-width: 8em\">{cipher}</th>"
tableContent += "</tr>"

for chromeVersion in allChromeVersions:
    row = f"<tr><th>Chromium {chromeVersion}</th>"

    for cipher in allCiphers:
        for key, value in tableData.items():
            if key[0] == cipher and key[1] == chromeVersion:
                style = "text-align: center;"
                if value == "ok":
                    style += "background-color: #00FF00"
                else:
                    style += "background-color: #FF0000; color: white;"

                row += f"<td style=\"{style}\">{value}</td>"

    row += "</tr>"
    tableContent += row


# Write output html to file
finalHtml = htmlTemplate.replace("%TABLE%", tableContent)
with open("results.html", "w") as f:
    f.write(finalHtml)
