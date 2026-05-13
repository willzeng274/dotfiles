#!/usr/bin/env python3
"""
Spotify to Slack Status Sync (macOS)

Author: William (william@polymarket.com)

Reads the currently playing track from the Spotify desktop app via
AppleScript and updates your Slack status. No Spotify API key or
Premium account required.

Run in the foreground:
    python3 spotify_slack_sync.py

Run in the background, writing logs to a file:
    nohup python3 spotify_slack_sync.py > /tmp/spotify_slack_sync.log 2>&1 &

Stop (foreground):
    Press Ctrl+C. The script clears your Slack status on exit.

Stop (background):
    pgrep -f spotify_slack_sync.py
    kill <PID>
"""

import subprocess
import json
import time
import os
import sys
import urllib.request
import urllib.error
import signal

# Config
POLL_INTERVAL = 5  # seconds between Spotify polls
SLACK_TOKEN = os.environ.get("SLACK_TOKEN", "REPLACE_WITH_SLACK_USER_TOKEN")
STATUS_EMOJI = ":spotify:"
CLEAR_WHEN_PAUSED = True

# Cache of the last status pushed to Slack, so we only call the API when the track changes.
last_status_text = None


def get_spotify_info():
    """Use AppleScript to read the current track from Spotify desktop app."""
    script = """
    if application "Spotify" is running then
        tell application "Spotify"
            if player state is playing then
                set trackName to name of current track
                set artistName to artist of current track
                return trackName & " | " & artistName
            else
                return "PAUSED"
            end if
        end tell
    else
        return "NOT_RUNNING"
    end if
    """
    try:
        result = subprocess.run(
            ["osascript", "-e", script], capture_output=True, text=True, timeout=5
        )
        output = result.stdout.strip()
        if output in ("NOT_RUNNING", "PAUSED", ""):
            return None
        parts = output.split(" | ", 1)
        if len(parts) == 2:
            return {"track": parts[0], "artist": parts[1]}
        return {"track": output, "artist": ""}
    except (subprocess.TimeoutExpired, FileNotFoundError):
        return None


def set_slack_status(text, emoji):
    """Update Slack profile status via the Web API."""
    profile = {"status_text": text, "status_emoji": emoji, "status_expiration": 0}
    data = json.dumps({"profile": profile}).encode("utf-8")

    req = urllib.request.Request(
        "https://slack.com/api/users.profile.set",
        data=data,
        headers={
            "Authorization": f"Bearer {SLACK_TOKEN}",
            "Content-Type": "application/json; charset=utf-8",
        },
        method="POST",
    )
    try:
        with urllib.request.urlopen(req, timeout=10) as resp:
            body = json.loads(resp.read().decode())
            if not body.get("ok"):
                print(f"  Slack API error: {body.get('error', 'unknown')}")
                return False
            return True
    except urllib.error.URLError as e:
        print(f"  Network error: {e}")
        return False


def clear_slack_status():
    """Remove the Slack status."""
    return set_slack_status("", "")


def truncate(text, max_len=100):
    """Slack status_text has a 100-char limit."""
    return text if len(text) <= max_len else text[: max_len - 1] + "..."


def main():
    global last_status_text

    if not SLACK_TOKEN:
        print("ERROR: Set SLACK_TOKEN environment variable first.")
        print('  export SLACK_TOKEN="xoxp-..."')
        sys.exit(1)

    # Clear the Slack status on exit so it doesn't get stuck showing the last track.
    def handle_exit(sig, frame):
        print("\nShutting down - clearing Slack status...")
        clear_slack_status()
        sys.exit(0)

    signal.signal(signal.SIGINT, handle_exit)
    signal.signal(signal.SIGTERM, handle_exit)

    print("Spotify -> Slack sync running  (Ctrl+C to stop)")
    print(f"   Polling every {POLL_INTERVAL}s\n")

    while True:
        info = get_spotify_info()

        if info:
            status = truncate(f"{info['track']} - {info['artist']}")
            if status != last_status_text:
                print(f"  > {status}")
                if set_slack_status(status, STATUS_EMOJI):
                    last_status_text = status
        elif CLEAR_WHEN_PAUSED and last_status_text is not None:
            print("  Spotify paused/closed - clearing status")
            if clear_slack_status():
                last_status_text = None

        time.sleep(POLL_INTERVAL)


if __name__ == "__main__":
    main()
