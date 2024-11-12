#!/bin/sh

if [ "$DESKTOP_SESSION" = "cinnamon" ]; then 
   sleep 20s
   killall conky
   cd "$HOME/.conky/kayleigh"
   conky -c "$HOME/.conky/kayleigh/kayleigh" &
   exit 0
fi