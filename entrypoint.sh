#!/bin/bash
# 
# This is the entrypoint for the Switchboard Server docker image.
# The purpose of this script is to aid in passing command line arguments, based on the environment variables.

/sbin/switchboardserver --sql="$USE_SQL" --mdb_host="$MARIADB_HOST" --mdb_user="$MARIADB_USER" --mdb_pass="$MARIADB_PASS" --mdb_db="$MARIADB_DB" --token="$BOT_TOKEN" --cdn="$CDN_URL"