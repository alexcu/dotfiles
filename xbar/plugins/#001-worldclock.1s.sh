#!/bin/bash

# Display UTC in the menubar, and one or more additional zones in the drop down.
# The current format (HH:MM:SS) works best with a one second refresh, or alter
# the format and refresh rate to taste.
#
# <xbar.title>World Clock</xbar.title>
# <xbar.version>v1.0</xbar.version>
# <xbar.author>Adam Snodgrass</xbar.author>
# <xbar.author.github>asnodgrass</xbar.author.github>
# <xbar.desc>Display current UTC time in the menu bar, with various timezones in the drop-down menu</xbar.desc>
# <xbar.image>https://cloud.githubusercontent.com/assets/6187908/12207887/464ff8b2-b617-11e5-9d61-787eed228552.png</xbar.image>

ZONES="Australia/Sydney Europe/London America/New_York America/Los_Angeles"
echo "$(date -u +'%H:%M:%S UTC')  •  $(TZ=Europe/London date +'%H:%M:%S') LHR"
echo '---'
for zone in $ZONES; do
  echo "$(TZ=$zone date +'%H:%M:%S %z') $zone"
done
