#!/bin/bash

# smart_monitor_combined_by_serial.sh
# Logs and alerts on CRC errors by Serial Number instead of device name

LOGDIR="$HOME/scripts/monitoring/logs"
LOGFILE="$LOGDIR/smart_crc_current_by_serial.log"
PREVLOG="$LOGDIR/smart_crc_previous_by_serial.log"
EMAIL="youraddress@gmail.com"
HOSTNAME=$(hostname)

mkdir -p "$LOGDIR"

echo "SMART CRC Error Report by Serial for $HOSTNAME - $(date)" > "$LOGFILE"
echo "--------------------------------------------------------------" >> "$LOGFILE"
printf "%-20s %-6s %-12s %-10s %-10s %-8s\n" "SERIAL" "DEV" "HCTL" "CRC_ERR" "MODEL" "PORT_HINT" >> "$LOGFILE"
echo "--------------------------------------------------------------" >> "$LOGFILE"

for disk in /dev/sd?; do
    DEV=$(basename $disk)
    HCTL=$(lsblk -no HCTL $disk 2>/dev/null)
    SERIAL=$(udevadm info --query=all --name=$disk | grep ID_SERIAL= | cut -d= -f2)
    MODEL=$(lsblk -no MODEL $disk)
    CRC=$(smartctl -a $disk | grep -i "CRC_Error" | awk '{print $NF}')
    PORT_HINT=$(echo $HCTL | cut -d: -f1)
    printf "%-20s %-6s %-12s %-10s %-10s %-8s\n" "$SERIAL" "$DEV" "$HCTL" "$CRC" "$MODEL" "$PORT_HINT" >> "$LOGFILE"
done

# If no previous log exists, save current as baseline
if [ ! -f "$PREVLOG" ]; then
    cp "$LOGFILE" "$PREVLOG"
    echo "No previous serial-based log found. Baseline created."
    exit 0
fi

# Compare by serial only (first column), alert if CRC increased
CHANGES=$(join -1 1 -2 1 <(sort "$PREVLOG" | grep -v "^--" | grep -v "^SMART" | grep -v "^SERIAL") <(sort "$LOGFILE" | grep -v "^--" | grep -v "^SMART" | grep -v "^SERIAL") | awk '{if ($4 < $10) print "CRC INCREASED for " $1 ": " $4 " → " $10 }')

if [ -n "$CHANGES" ]; then
    echo -e "Subject: CRC ERROR CHANGE on $HOSTNAME\n\nThe following drives have increased CRC error counts:\n\n$CHANGES" | msmtp "$EMAIL"
    echo "ALERT: CRC error changes detected by serial and emailed to $EMAIL"
else
    echo "No CRC changes by serial detected."
fi

# Update baseline
cp "$LOGFILE" "$PREVLOG"
