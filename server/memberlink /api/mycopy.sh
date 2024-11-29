#!/bin/bash

# Define source and destination paths
source="/Applications/XAMPP/xamppfiles/htdocs/memberlink/api"
destination="/Users/mahmoud/Desktop/Flutter/my_member_link_admin/my_member_link/server/memberlink/api"

# Check if source directory exists
if [ ! -d "$source" ]; then
  echo "Source folder $source does not exist."
  exit 1
fi

# Create destination folder if it doesn't exist
if [ ! -d "$destination" ]; then
  mkdir -p "$destination"
fi

# Copy files from source to destination
cp -r "$source"/* "$destination"

# Confirmation message
echo "Files have been copied successfully from $source to $destination."
