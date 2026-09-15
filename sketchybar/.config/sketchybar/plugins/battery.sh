#!/bin/sh

PERCENTAGE="$(pmset -g batt | grep -Eo "\d+%" | cut -d% -f1)"
CHARGING="$(pmset -g batt | grep 'AC Power')"

if [ "$PERCENTAGE" = "" ]; then
  exit 0
fi

COLOR=0xffcad3f5 # white, ported from mehd-io/dotfiles (backup-yabai branch) color palette
case "${PERCENTAGE}" in
  9[0-9]|100) ICON=""
  ;;
  [6-8][0-9]) ICON=""
  ;;
  [3-5][0-9]) ICON=""
  ;;
  [1-2][0-9]) ICON=""; COLOR=0xfff5a97f # orange, low battery warning
  ;;
  *) ICON=""; COLOR=0xffed8796 # red, critical battery warning
esac

if [[ "$CHARGING" != "" ]]; then
  ICON=""
  COLOR=0xffcad3f5
fi

# The item invoking this script (name $NAME) will get its icon and label
# updated with the current battery status
sketchybar --set "$NAME" icon="$ICON" icon.color="$COLOR" label="${PERCENTAGE}%"
