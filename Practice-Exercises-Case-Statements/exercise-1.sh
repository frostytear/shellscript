#!/bin/bash

case "$1" in
  start)
    # command here
    /tmp/sleep-walking-server &
  ;;
  stop)
    # command here
    kill $(cat /tmp/sleep-walking-server.pid)
  ;;
  *)
    echo "Usage: $0 {start|stop}"
    exit 1
  ;;
esac
