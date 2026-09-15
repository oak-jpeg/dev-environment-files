#!/bin/sh

VPN_SERVICE="Minerva-VPS"
STATUS="$(scutil --nc status "$VPN_SERVICE" 2>/dev/null | head -1)"

case "$STATUS" in
  Connected)
    ICON=""
    COLOR=0xffa6da95 # green
    ;;
  Connecting|Disconnecting)
    ICON=""
    COLOR=0xfff5a97f # orange
    ;;
  *)
    ICON=""
    COLOR=0xff939ab7 # grey, disconnected
    ;;
esac

sketchybar --set "$NAME" icon="$ICON" icon.color="$COLOR"
