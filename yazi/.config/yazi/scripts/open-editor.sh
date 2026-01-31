#!/bin/bash
if [ -n "$ZELLIJ" ]; then
    # Inside Zellij: open in floating pane
    zellij run --floating --close-on-exit --x 5% --y 5% --width 90% --height 90% -- micro "$@"
else
    # Outside Zellij: open directly
    micro "$@"
fi
