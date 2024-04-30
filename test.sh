#!/bin/bash

# Check if both parameters are provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 HOSTNAME IP_ADDRESS"
    exit 1
fi

# Read parameters
HOSTNAME=$1
IP_ADDRESS=$2

# Use curl to make an HTTP request
response=$(curl -s -o /dev/null -w "%{http_code}" --header "Host: $HOSTNAME" http://$IP_ADDRESS)

# Print the HTTP status code and a friendly message
echo "HTTP response code: $response"
if [ "$response" -eq 200 ]; then
    echo "Connection to $HOSTNAME at $IP_ADDRESS was successful!"
else
    echo "Failed to connect to $HOSTNAME at $IP_ADDRESS. Response code: $response"
fi
