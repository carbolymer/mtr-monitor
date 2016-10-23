#!/bin/sh

CYCLES=30
INTERVAL=40
MTR_HOST="8.8.8.8"
MTR_HOST2="reddit.com"
MTR_HOST3="facebook.com"
INFLUXDB_HOST="localhost"
INFLUXDB_PORT=51113
INFLUXDB_ADMIN_PORT=51112
GRAFANA_PORT=51111

# END OF CONFIG

function monitor_mtr() {
    ( mtr --report --json --report-cycles $CYCLES $MTR_HOST | ./save_data.py --host $INFLUXDB_HOST --port $INFLUXDB_PORT ) &
    ( mtr --report --json --report-cycles $CYCLES $MTR_HOST2 | ./save_data.py --host $INFLUXDB_HOST --port $INFLUXDB_PORT ) &
    ( mtr --report --json --report-cycles $CYCLES $MTR_HOST3 | ./save_data.py --host $INFLUXDB_HOST --port $INFLUXDB_PORT ) &
}

sudo docker run -d \
    -p $INFLUXDB_ADMIN_PORT:8083 \
    -p $INFLUXDB_PORT:8086 \
    -v /etc/localtime:/etc/localtime:ro \
    -v $PWD/influxdb:/var/lib/influxdb \
    influxdb:1.0.2-alpine

sudo docker run -d \
    -p $GRAFANA_PORT:3000 \
    -v /etc/localtime:/etc/localtime:ro \
    -v $PWD/grafana:/var/lib/grafana/ \
    -e "GF_SECURITY_ADMIN_PASSWORD=grafana" \
    -e "TZ=Europe/Warsaw" \
    grafana/grafana


while true; do
    monitor_mtr
    sleep $INTERVAL
done
