#!/usr/bin/env python
import argparse
import json
import sys
import datetime as dt

from influxdb import InfluxDBClient, SeriesHelper

db_name = 'mtr-monitor'
user = 'root'
password = 'root'


class HubEntry(SeriesHelper):
    class Meta:
        series_name = 'mtr.result.{destination}'
        fields = ['time', 'count', 'loss', 'snt', 'last', 'avg', 'best', 'wrst', 'stdev']
        tags = ['destination', 'host']


def get_cmd_arguments():
    parser = argparse.ArgumentParser(description='JSON parser')
    parser.add_argument('--host', default='localhost', help='influxdb host')
    parser.add_argument('--port', default=51113, help='influxdb port')

    return parser.parse_args()


def main():
    args = get_cmd_arguments()
    db_client = InfluxDBClient(args.host, args.port, user, password, db_name)
    db_client.create_database(db_name)
    HubEntry.Meta.client = db_client

    mtr_result = json.load(sys.stdin)
    # ping destination
    destination = mtr_result['report']['mtr']['dst']
    report_time = dt.datetime.utcnow()
    for hub in mtr_result['report']['hubs']:
        # persist the hub entry
        HubEntry(
            time=report_time,
            destination=destination,
            host=hub['host'],
            count=hub['count'],
            loss=hub['Loss%'],
            snt=hub['Snt'],
            last=hub['Last'],
            avg=hub['Avg'],
            best=hub['Best'],
            wrst=hub['Wrst'],
            stdev=hub['StDev']
        )
    HubEntry.commit()


if __name__ == '__main__':
    main()
