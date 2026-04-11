#!/bin/bash
#
# This will assume we are using the official server.
#

# Generate MD5 hash from first argument
#hash=$(echo -n "$1" | md5sum | awk '{print $1}')
# Hardcoded password to simply 'test'

# Send request
curl -i -X PUT \
  -H "Content-Type: application/json" \
  -d '{"auth":"098f6bcd4621d373cade4e832627b4f6"}' \
  "https://cdn.zontreck.com/user/1234apitest"