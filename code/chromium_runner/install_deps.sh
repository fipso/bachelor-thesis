#!/bin/bash

# Update apt-file to ensure the latest package data
apt-file update

# Escape spaces in the destination path
DESTINATION="${1// /\\ }"

# Find missing files using ldd
FILES=$(eval ldd "$DESTINATION" | grep "not found" | awk '{print $1}' | paste -s -d ' ')
echo "Missing libraries: $FILES"

# Initialize an empty string to hold all installable packages
INSTALL_PACKAGES=""

# Loop through each missing file
for FILE in $FILES; do
  echo "Searching for $FILE..."

  # Search for the file in the apt repository using regex to match exact filenames
  RESULTS=$(apt-file search --regex "/$FILE\$")

  # Filter results to find the most relevant package
  PACKAGE=$(echo "$RESULTS" | awk -F ': ' '{print $1}' | sort | uniq | grep -i "$(echo $FILE | sed 's/\..*//')" | head -n 1)

  if [ -z "$PACKAGE" ]; then
    # If no package is found, try a broader search
    PACKAGE=$(echo "$RESULTS" | awk -F ': ' '{print $1}' | sort | uniq | head -n 1)
  fi

  # Check if a package was found and append it to the installation list
  if [ ! -z "$PACKAGE" ]; then
    echo "Selected package for installation: $PACKAGE"
    INSTALL_PACKAGES="$INSTALL_PACKAGES $PACKAGE"
  else
    echo "No appropriate package found for $FILE"
  fi
done

# Install all selected packages at once if any are found
if [ ! -z "$INSTALL_PACKAGES" ]; then
  echo "Installing packages: $INSTALL_PACKAGES"
  apt-get install -y $INSTALL_PACKAGES
else
  echo "No packages to install."
fi
