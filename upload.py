#!/usr/bin/env python2

import sys
import argparse
from os.path import basename
import urllib2


def request(args, url_part):
    url = "http://%s/fwu/%s" %(args.host, url_part)
    response = urllib2.urlopen(url)
    data = response.read()
    print "%s => %s" % (url, data)
    if data == "OK":
        return True
    else:
        return False


def main():
    parser = argparse.ArgumentParser(description='ESP8266 Lua script uploader.')
    parser.add_argument('-H', '--host',    default='192.168.0.105', help='Host name')
    parser.add_argument('-f', '--src',     default='main.lua',     help='Source file on computer, default main.lua')
    parser.add_argument('-t', '--dest',    default=None,           help='Destination file on MCU, default to source file name')
    args = parser.parse_args()

    if args.dest is None:
        args.dest = basename(args.src)

    f = open(args.src, "r")
    if not request(args, "open/" + args.dest):
        print("Error opening file")
        return
    while True:
        data = f.read(64)
        if len(data) == 0:
            request(args, "close")
            f.close()
            break
        else:
            if not request(args, "write/%s" % data.encode('hex')):
                print("Error writing file")
                break

if __name__ == "__main__":
    main()

