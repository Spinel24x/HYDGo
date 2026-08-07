#!/bin/bash

# Health check for Xray
if pgrep -x "xray" > /dev/null; then
    # Check if Xray is responding
    if curl -sf http://localhost:8080/ > /dev/null 2>&1; then
        exit 0
    fi
fi

# If we get here, something is wrong
exit 1
