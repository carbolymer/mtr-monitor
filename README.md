# MTR monitor

Simple MTR runner which stores data to InfluxDB and allows to preview stored data using Grafana dashboards

![sample dashboard](grafana/mtr_dashboard_screenshot.png)

## Installation
### Requrements
  * `bash` shell
  * `python3`
  * `docker` (optional - required for standalone grafana and influxdb)
  * `mtr`
  * `influxdb` python package - using the command `pip3 install --upgrade influxdb`

## How to run
1. Edit `mtr-monitor.sh` to adjust settings to your own liking
1. Run `sudo make install` to install mtr-monitor to `/opt/mtr-monitor`
1. Start the systemd service `systemctl start mtr-monitor`
1. Open http://127.0.0.1:51111 to access Grafana UI

## How to access InfluxDB
`./influx-cli.sh` will connect to the docker image and open CLI

## Notes

The `mtr-monitor.sh` script when run for the first time downloads grafana and influxdb docker images and creates new containers for them.
During consecutive runs it just starts already existing docker containers.
The created containers will be always started when the docker service starts.
If you want to change parameters of the container, e.g. ports, you need to remove them (e.g. `docker container rm mtr-influxdb`) and just start `mtr-monitor.sh`.

Make sure influxdb is seen in ther python site-packages:
`python -c "from distutils.sysconfig import get_python_lib; print(get_python_lib())" | xargs ls`
