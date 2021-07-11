#!/usr/bin/env bash

CONKYFOLDER=$(dirname $(realpath $0))

sleep 7        # time (in s) for the DE to start; use ~20 for Gnome or KDE, less for Xfce/LXDE etc

# # Clock Rings
# conky -d -c $CONKYFOLDER/clock_rings/clock_rings

# # Sands of Time
# conky -d -c $CONKYFOLDER/sands_time/clock
# conky -d -c $CONKYFOLDER/sands_time/sys
# conky -d -c $CONKYFOLDER/sands_time/user

# # QlockTwo
# conky -d -c $CONKYFOLDER/qlock_two/qlocktwo

# Rings
conky -d -c $CONKYFOLDER/rings/rings

# User
conky -d -c $CONKYFOLDER/user/user
