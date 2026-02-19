#!/bin/bash
# Open file in Typora if available, otherwise fallback to default opener.
# On macOS, sizes the window to ~80% of the screen and centers it.

if command -v open >/dev/null 2>&1; then
    open -a Typora "$@" || open "$@"

    # Resize and center the Typora window via AppleScript
    osascript -e '
    tell application "System Events"
        tell application process "Typora"
            set retries to 0
            repeat while retries < 10
                try
                    set win to first window
                    exit repeat
                on error
                    delay 0.1
                    set retries to retries + 1
                end try
            end repeat
        end tell
    end tell

    tell application "Finder"
        set screenBounds to bounds of window of desktop
        set screenWidth to item 3 of screenBounds
        set screenHeight to item 4 of screenBounds
    end tell

    set winWidth to round (screenWidth * 0.8)
    set winHeight to round (screenHeight * 0.8)
    set winX to round ((screenWidth - winWidth) / 2)
    set winY to round ((screenHeight - winHeight) / 2)

    tell application "Typora"
        set bounds of front window to {winX, winY, winX + winWidth, winY + winHeight}
    end tell
    ' &
    exit 0
fi

if command -v typora >/dev/null 2>&1; then
    typora "$@"
    exit 0
fi

if command -v xdg-open >/dev/null 2>&1; then
    xdg-open "$@"
    exit 0
fi

if command -v gio >/dev/null 2>&1; then
    gio open "$@"
    exit 0
fi

echo "No Typora or system opener found." >&2
exit 1
