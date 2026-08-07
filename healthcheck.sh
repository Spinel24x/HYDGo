#!/bin/bash
pgrep -x "xray" > /dev/null && exit 0 || exit 1
