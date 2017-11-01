#!/usr/bin/env bash
# soundtime.sh: Randomly play sounds from the current directory until a timer expires.
set -e

# Parse the timeout
if [ $# -lt 1 ]; then
    echo "Please specify a timeout (e.g. 100s)"
    exit 1;
fi
TIMEOUT="${1}"

# Where are we
SCRIPT_DIR="$(dirname $0)"

# What files are next to us
SONGS=()
while read SONG_FILE; do
    echo "Found ${SONG_FILE}"
    SONGS+=("${SONG_FILE}")
done < <(find "${SCRIPT_DIR}" -type f -name "*.mp3" | shuf)


# TODO: handle the kill signal nicely and don't print.

# Save our PID
MAIN_PID=$$
PLAYER_PID=$$
# Launch a subshell to kill us
# Make sure it will also kill all our child processes
(sleep "${TIMEOUT}"; pkill -TERM -P "${MAIN_PID}") &
# Keep track of it
WATCHDOG_PID="${!}"


while true; do
    # Until we run out of time
    for SONG_FILE in "${SONGS[@]}"; do
        mplayer "${SONG_FILE}"
    done
done

# Make sure to clean up the watchdog
kill "${WATCHDOG_PID}"
