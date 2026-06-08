#!/bin/bash
pkill -f aw-server
pkill -f aw-watcher
pkill -f aw-sync
notify-send "ActivityWatch stopped"
