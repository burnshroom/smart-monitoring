#!/bin/bash
LOGDIR="$HOME/scripts/monitoring/logs"
mkdir -p "$LOGDIR"
NOW=$(date +%F)
LOGFILE="$LOGDIR/smart_health_$NOW.log"
ALERTFILE="$LOGDIR/alert_triggered.log"
EMAIL="your@email.com"

touch "$ALERTFILE"

for disk in /dev/sd?; do
    echo "=== $disk ===" >> "$LOGFILE"
    smartctl -a "$disk" | grep -E "Model|Serial|Reallocated_Sector_Ct|Current_Pending_Sector|UDMA_CRC_Error_Count" >> "$LOGFILE"
done

# Compare with previous day (if exists)
YESTERDAY=$(date -d "yesterday" +%F)
PREVLOG="$LOGDIR/smart_health_$YESTERDAY.log"

if [[ -f "$PREVLOG" ]]; then
    CHANGES=$(diff "$PREVLOG" "$LOGFILE")
    if [[ -n "$CHANGES" ]]; then
        echo "🔴 SMART changes detected!" | tee -a "$ALERTFILE"
        echo "$CHANGES" >> "$ALERTFILE"
        mail -s "SMART Alert on $(hostname)" "$EMAIL" < "$ALERTFILE"
    fi
fi
