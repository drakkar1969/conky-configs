#!/usr/bin/env bash

CONKYFOLDER=$(dirname $(realpath $0))

sleep 7        # time (in s) for the DE to start; use ~20 for Gnome or KDE, less for Xfce/LXDE etc

# # Clock Rings
# conky -d -c $CONKYFOLDER/clock_rings/clock_rings.conf

# # QlockTwo
# conky -d -c $CONKYFOLDER/qlock_two/qlocktwo.conf

# Rings
conky -d -c $CONKYFOLDER/rings/rings.conf

# # User
# conky -d -c $CONKYFOLDER/user/user.conf

# MPRIS
conky -d -c $CONKYFOLDER/mpris/mpris.conf

# # Dials
# conky -d -c $CONKYFOLDER/dials/dials.conf
