#!/usr/bin/env bash
set -euo pipefail

CONFIG_DIR="$HOME/.config/pushups"
CONFIG_FILE="$CONFIG_DIR/config"
LOG_FILE="$CONFIG_DIR/pushups.log"
STATE_FILE="$CONFIG_DIR/state"
DEBUG_LOG="$CONFIG_DIR/debug.log"
SCRIPT_TARGET="$HOME/bin/hourly-standup-reminder.sh"
PLIST_FILE="$HOME/Library/LaunchAgents/com.user.hourlypushups.plist"

mkdir -p "$CONFIG_DIR"

# Initialize config if not exists
if [[ ! -f $CONFIG_FILE ]]; then
  cat >"$CONFIG_FILE" <<EOF
start_date=$(date +%Y-%m-%d)
reps=10
EOF
  echo "$(date '+%Y-%m-%d %H:%M:%S') [INIT] Created new config with reps=10" >>"$DEBUG_LOG"
fi

# === Commands ===
case "${1:-}" in
  stats)
    if [[ ! -f $LOG_FILE ]]; then
      echo "No pushup data yet!"
      exit 0
    fi
    echo "📊 Pushup Stats:"
    awk -F',' '{ total[$1] += $3 } END {
        for (d in total) {
            print d ": " total[d] " pushups"
            grand += total[d]
        }
        print "----------------------"
        print "Total: " grand " pushups"
    }' "$LOG_FILE" | sort
    exit 0
    ;;

  install)
    echo "🧾 Creating LaunchAgent at $PLIST_FILE"
    mkdir -p "$HOME/Library/LaunchAgents"
    cat >"$PLIST_FILE" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>com.user.hourlypushups</string>
  <key>ProgramArguments</key>
  <array>
    <string>$SCRIPT_TARGET</string>
  </array>
  <key>StartCalendarInterval</key>
  <array>
$(for m in $(seq 0 5 55); do echo "    <dict><key>Minute</key><integer>$m</integer></dict>"; done)
  </array>
  <key>StandardOutPath</key>
  <string>/tmp/hourlypushups.out</string>
  <key>StandardErrorPath</key>
  <string>/tmp/hourlypushups.err</string>
  <key>RunAtLoad</key>
  <true/>
</dict>
</plist>
EOF

    echo "🚀 Loading LaunchAgent..."
    launchctl unload "$PLIST_FILE" 2>/dev/null || true
    launchctl load "$PLIST_FILE"

    echo "✅ Installed and scheduled to run every 5 minutes."
    exit 0
    ;;
esac

# Load config
source "$CONFIG_FILE"

# Load or reset daily state
current_day=$(date +%Y-%m-%d)
if [[ -f $STATE_FILE ]]; then
  source "$STATE_FILE"
  if [[ $state_day != "$current_day" ]]; then
    counter=0
    total_pushups=0
    last_alert_ts=0
  fi
else
  counter=0
  total_pushups=0
  last_alert_ts=0
fi

types=("Normal" "Wide" "Narrow" "Sidekick")

function save_state {
  cat >"$STATE_FILE" <<EOF
state_day=$current_day
counter=$counter
total_pushups=$total_pushups
last_alert_ts=$last_alert_ts
EOF
}

function screenIsUnlocked {
  [ "$(/usr/libexec/PlistBuddy -c "print :IOConsoleUsers:0:CGSSessionScreenIsLocked" /dev/stdin 2>/dev/null <<<"$(ioreg -n Root -d1 -a)")" != "true" ] && return 0 || return 1
}

# Main one-shot logic for LaunchAgent use
now_day=$(date +%Y-%m-%d)
now_ts=$(date +%s)
minute=$(date +%M)

# Only notify between :00–:30 of the current hour
within_window=false
if ((minute < 30)); then
  within_window=true
fi

if [[ $now_day != "$current_day" ]]; then
  current_day="$now_day"
  counter=0
  total_pushups=0
  last_alert_ts=0
  save_state

  # Weekly progression
  start_ts=$(date -jf "%Y-%m-%d" "$start_date" +%s)
  today_ts=$(date -jf "%Y-%m-%d" "$now_day" +%s)
  days_since_start=$(((today_ts - start_ts) / 86400))
  weeks_since_start=$((days_since_start / 7))
  weekday=$(date +%u)

  echo "$(date '+%Y-%m-%d %H:%M:%S') [DEBUG] Weekly check: day=$now_day weekday=$weekday weeks_since_start=$weeks_since_start reps=$reps" >>"$DEBUG_LOG"

  if [[ $weekday -eq 1 ]]; then
    if ((weeks_since_start > 0 && weeks_since_start % 2 == 0)); then
      old_reps=$reps
      reps=$((reps + (reps * 15 / 100)))
      echo "start_date=$start_date" >"$CONFIG_FILE"
      echo "reps=$reps" >>"$CONFIG_FILE"
      echo "$(date '+%Y-%m-%d %H:%M:%S') [INFO] ✅ Reps increased: $old_reps → $reps (week $weeks_since_start)" >>"$DEBUG_LOG"
    else
      echo "$(date '+%Y-%m-%d %H:%M:%S') [DEBUG] 💤 Skipping increment: week $weeks_since_start is not an increment week" >>"$DEBUG_LOG"
    fi
  else
    echo "$(date '+%Y-%m-%d %H:%M:%S') [DEBUG] 💤 Skipping increment: weekday=$weekday (only increments on Monday)" >>"$DEBUG_LOG"
  fi

  if [[ $weeks_since_start -eq 4 ]]; then
    osascript -e 'display notification "Time to test your max pushups and update the config!" with title "Week 5 Check-In"'
  fi
fi

if $within_window && screenIsUnlocked && ((now_ts - last_alert_ts >= 1800)); then
  type_index=$((counter % ${#types[@]}))
  pushup_type=${types[$type_index]}

  osascript -e "display notification \"Do $reps $pushup_type pushups!\nTotal today: $total_pushups\" with title \"Time to get up\""

  for i in {1..3}; do
    afplay /System/Library/Sounds/Hero.aiff
  done

  echo "$(date "+%Y-%m-%d,%H:%M:%S"),$pushup_type,$reps" >>"$LOG_FILE"

  total_pushups=$((total_pushups + reps))
  counter=$((counter + 1))
  last_alert_ts=$now_ts
  save_state

  echo "$(date '+%Y-%m-%d %H:%M:%S') [INFO] Pushup alert sent: $reps $pushup_type" >>"$DEBUG_LOG"
else
  echo "$(date '+%Y-%m-%d %H:%M:%S') [DEBUG] Skipped alert: within_window=$within_window screenIsUnlocked=$(screenIsUnlocked && echo true || echo false)" >>"$DEBUG_LOG"
fi
