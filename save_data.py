#!/usr/bin/env python3
import argparse
import json
import sys
import datetime as dt
import logging

from influxdb_client import InfluxDBClient, WritePrecision, Point
from influxdb_client.client.write_api import SYNCHRONOUS

logging.basicConfig(level=logging.INFO)

organization = ''
user = 'root'
token = ''
bucket = 'mtr'


def get_cmd_arguments():
    parser = argparse.ArgumentParser(description='JSON parser')
    parser.add_argument('--url', default='http://localhost:8086', help='influxdb url')
    return parser.parse_args()


def main():
    args = get_cmd_arguments()
    db_client = InfluxDBClient(url=args.url, token=token, org=organization)
    write_api = db_client.write_api(write_options=SYNCHRONOUS)

    mtr_result = json.load(sys.stdin)
    # ping destination
    destination = mtr_result['report']['mtr']['dst']
    report_time = dt.datetime.utcnow()

    for hub in mtr_result['report']['hubs']:
        # persist the hub entry
        # Modifying the data if needed so that is can be easily sorted in the event of more than 9 hops.
        if len(hub['count']) < 2:
            hop = "0" + hub['count'] + "-" + hub['host']
        else:
            hop = hub['count'] + "-" + hub['host']

        entry = Point(destination) \
                .tag('destination', destination) \
                .tag('hop', hop) \
                .field('loss', hub['Loss%']) \
                .field('snt', hub['Snt']) \
                .field('last', hub['Last']) \
                .field('avg', hub['Avg']) \
                .field('best', hub['Best']) \
                .field('wrst', hub['Wrst']) \
                .field('stdev', hub['StDev']) \
                .time(dt.datetime.utcnow(), WritePrecision.MS)

        write_api.write(bucket=bucket, record=entry)

if __name__ == '__main__':
    main()
