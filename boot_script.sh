#!/bin/sh

# reset in case battery_status script fails
echo 0 > /home/root/debian/home/buendia/battery_shutdown.txt

cd /home/root/gpio
python splash_screen.py &
sleep 30

# mount SD before anything else
mount /dev/mmcblk1p1 /home/root/debian/home/buendia/sd/

# SERVER STATUS
python server_status.py >> sd/server_status_log.txt 2>&1 &

# BATTERY STATUS
echo 101 > battery_charge.txt  # reset status file
# sleep briefly to allow default UART pin boot sequence to finish (a bug workaround)
sleep 15
python battery_status.py >> sd/battery_status_log.txt 2>&1 &

# OTHER SCRIPTS

# monitor LED scripts
sleep 20
#. scripts_check.sh >> sd/scripts_check_log.txt 2>&1 &

# prevent truncate errors from any missing files
touch sd/server_status_log.txt
touch sd/battery_status_log.txt
touch sd/battery_charge_log.txt

# truncate log files
. truncate_logs.sh  >> /dev/null 2>&1 &

# truncate battery log
truncate() { tail -$2 $1 > $1.tmp; cat $1.tmp > $1; rm $1.tmp; }
truncate sd/battery_charge_log.txt 1000

exit 0
