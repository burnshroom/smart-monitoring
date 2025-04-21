#!/bin/bash
LOGDIR="$HOME/scripts/monitoring/logs"
mkdir -p "$LOGDIR"
LOGFILE="$LOGDIR/weekly_smart_$(date +%F).log"

for disk in /dev/sd?; do
    echo "=== $disk ===" >> "$LOGFILE"
    smartctl -a "$disk" | grep -E "Model|Serial|Power_On_Hours|Temperature_Celsius|Reallocated_Sector_Ct|Current_Pending_Sector|UDMA_CRC_Error_Count" >> "$LOGFILE"
done

