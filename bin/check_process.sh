#!/bin/bash
# Check if process is running - initial version

process="java"
if pgrep -x "$process" >/dev/null
then
    echo "$process is running"
else
    echo "$process is NOT running"
fi