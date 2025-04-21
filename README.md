# Monitoring Scripts Overview

This folder contains automated health and monitoring scripts for SMART status, temperatures, and error detection.

| Script Name              | Schedule       | Description                                       | Log Location                        |
|--------------------------|----------------|---------------------------------------------------|-------------------------------------|
| smart_monitor.sh         | Daily @ 9 AM   | Monitors SMART errors and emails alerts on change| `~/scripts/monitoring/logs/`       |
| weekly_smart_log.sh      | Weekly @ 10 AM | Logs weekly SMART stats including temperatures    | `~/scripts/monitoring/logs/`       |
| (Your Other Script)      | (Time)         | (What it does)                                    | (Log path, if any)                 |

## Notes
- All logs are kept in the `logs/` subfolder of this directory.
- You can use `crontab -l` to verify scheduled tasks.
- Customize your email inside `smart_monitor.sh` (`EMAIL=` line).
