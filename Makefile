SHELL := /bin/bash

install:
	install -m 755 -d /opt/mtr-monitor
	cp -r grafana /opt/mtr-monitor/
	chown -R 472:472 /opt/mtr-monitor/grafana
	cp -r influxdb /opt/mtr-monitor/
	chown -R root:root /opt/mtr-monitor/influxdb
	install -D -m 644 grafana.ini /opt/mtr-monitor/grafana.ini
	install -D -m 744 influx-cli.sh /opt/mtr-monitor/influx-cli.sh
	install -D -m 744 mtr-monitor.sh /opt/mtr-monitor/mtr-monitor.sh
	install -D -m 644 README.md /opt/mtr-monitor/README.md
	install -D -m 644 requirements.txt /opt/mtr-monitor/requirements.txt
	install -D -m 744 save_data.py /opt/mtr-monitor/save_data.py
	install -D -m 744 mtr-monitor.service /usr/lib/systemd/system/mtr-monitor.service
	python3 -m venv /opt/mtr-monitor/venv
	source /opt/mtr-monitor/venv/bin/activate && pip3 install -r /opt/mtr-monitor/requirements.txt
	
