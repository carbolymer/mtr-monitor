#!/bin/bash

# number of pings sent
CYCLES=30
# inverval between MTR tests in seconds
INTERVAL=40
MTR_HOSTS=("8.8.8.8" "reddit.com" "facebook.com")

# set to no to not download & start docker image with influx
INFLUXDB_DOCKER="yes"
# if you need to change it, change also in influx-cli.sh
INFLUXDB_DOCKER_CONTAINER_NAME="mtr-influxdb"
INFLUXDB_HOST="localhost"
INFLUXDB_PORT=8086
# docker image parameter only
INFLUXDB_ADMIN_PORT=51112
# docker image version
INFLUXDB_VERSION=1.7-alpine

# set to "no" to not download & start grafana docker image
GRAFANA_DOCKER="yes"
GRAFANA_DOCKER_CONTAINER_NAME="mtr-grafana"
# password for admin user
GRAFANA_ADMIN_PASSWORD="grafana"
GRAFANA_PORT=51111
TIMEZONE="Europe/Warsaw"

# END OF CONFIG

WORKDIR="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

function monitor_mtr() {
  for MTR_HOST in "${MTR_HOSTS[@]}"; do
    ( mtr --report --json --report-cycles $CYCLES $MTR_HOST | $WORKDIR/save_data.py --url "http://$INFLUXDB_HOST:$INFLUXDB_PORT" ) &
  done
}

which mtr &>/dev/null
if [ $? -eq 1 ]; then
  echo "mtr is not available on this system - it is required for this script to work"
  exit 1
fi

if [[ $INFLUXDB_DOCKER == "yes" ]] ; then
  if [ ! "$(sudo docker ps -a | grep $INFLUXDB_DOCKER_CONTAINER_NAME)" ]; then
    sudo docker run -d \
      --restart=unless-stopped \
      --name="$INFLUXDB_DOCKER_CONTAINER_NAME" \
      -p $INFLUXDB_ADMIN_PORT:8083 \
      -p $INFLUXDB_PORT:8086 \
      -v /etc/localtime:/etc/localtime:ro \
      -v $WORKDIR/influxdb:/var/lib/influxdb \
      influxdb:$INFLUXDB_VERSION
  else
    sudo docker start $INFLUXDB_DOCKER_CONTAINER_NAME
  fi
  echo "starting influxdb docker container"
fi

if [[ $GRAFANA_DOCKER == "yes" ]]; then
  if [ ! "$(sudo docker ps -a | grep $GRAFANA_DOCKER_CONTAINER_NAME)" ]; then
    sudo docker run -d \
      --restart=unless-stopped \
      --name="$GRAFANA_DOCKER_CONTAINER_NAME" \
      -p $GRAFANA_PORT:3000 \
      -v /etc/localtime:/etc/localtime:ro \
      -v $WORKDIR/grafana.ini:/etc/grafana/grafana.ini:ro \
      -v $WORKDIR/grafana:/var/lib/grafana/ \
      -e "GF_SECURITY_ADMIN_PASSWORD=$GRAFANA_ADMIN_PASSWORD" \
      -e "TZ=$TIMEZONE" \
      grafana/grafana
  else
    sudo docker start $GRAFANA_DOCKER_CONTAINER_NAME
  fi
  echo "starting grafana docker container"
fi

# wait for influx to initialize
sleep 5

source "${WORKDIR}/venv/bin/activate"
while true; do
  monitor_mtr
  sleep $INTERVAL
done
