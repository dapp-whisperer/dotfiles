#!/bin/bash
# Render markdown for Yazi preview pane via lowdown.
# Strips OSC 8 hyperlink escape codes that break table rendering in piper.
lowdown -tterm --term-columns="$2" --term-no-links --term-hpadding=2 "$1" | perl -pe 's/\e\]8;;.*?\e\\//g'
