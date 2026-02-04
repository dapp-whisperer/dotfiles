#!/bin/bash
# Open file in Typora if available, otherwise fallback to default opener.

if command -v open >/dev/null 2>&1; then
    open -a Typora "$@" || open "$@"
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
