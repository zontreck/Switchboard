#!/bin/bash
# 
# This is the entrypoint for the Switchboard Server docker image.
# The purpose of this script is to aid in passing command line arguments, based on the environment variables.

/app/bin/switchboard --botpsk "$SB_BOTPSK" --token "$BOT_TOKEN"