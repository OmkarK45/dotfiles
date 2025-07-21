#!/bin/bash

LOCKFILE="$HOME/.devtools-opened.lock"
GRACE_PERIOD=10  # seconds

# Step 1: Check if DevTools is open
DEVTOOLS_FOUND=$(osascript <<EOF
tell application "Google Chrome"
	set found to false
	repeat with w in windows
		repeat with i from 1 to (count of tabs of w)
			set tabTitle to title of tab i of w
			if tabTitle contains "React Native DevTools" then
				set active tab index of w to i
				set index of w to 1
				activate
				set found to true
				exit repeat
			end if
		end repeat
		if found then exit repeat
	end repeat
	if found then
		return "FOUND"
	else
		return "NOTFOUND"
	end if
end tell
EOF
)

# Step 2: If DevTools not open, check for recent reopen
if [[ "$DEVTOOLS_FOUND" == "NOTFOUND" ]]; then
  now=$(date +%s)

  if [[ -f "$LOCKFILE" ]]; then
    lastOpened=$(cat "$LOCKFILE")
    elapsed=$((now - lastOpened))
    if (( elapsed < GRACE_PERIOD )); then
      echo "DevTools was just closed — skip reopen"
      exit 0
    fi
  fi

  # Step 3: Open via iTerm2
  osascript <<EOF
tell application "iTerm"
	activate
	set targetTabName to "yarn (esbuild)"
	repeat with aWindow in windows
		repeat with aTab in tabs of aWindow
			set tabSession to session 1 of aTab
			if name of tabSession contains targetTabName then
				select aTab
				tell tabSession to write text "j"
				delay 0.5
				tell tabSession to write text "1"
				return
			end if
		end repeat
	end repeat
end tell
EOF

  # Step 4: Write lock file
  echo "$now" > "$LOCKFILE"
fi