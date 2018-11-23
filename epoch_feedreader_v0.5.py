#!/usr/bin/env python
# HPE Aruba TAC ALE epoch time converter
# Not officially supported / maintained by HPE Aruba Networks
# For HPE Aruba TAC use only
# Copyright (c) HPE Aruba Networks 2018 - All rights reserved
# ----------------------------------------------------------------------------------

# imports - argparse is required for ALE
# to install argparse run 'yum install python-argparse'

import os, sys, subprocess, time, re, argparse, datetime
from threading import Thread

# parse arguments
parser = argparse.ArgumentParser(description='Read ZMQ epoch timestamps and convert to UTC')
parser.add_argument('-f', '--filename', type=str, help='output filename', required=True)
parser.add_argument('-t', '--time', type=int, help='time duration that ZMQ will be monitored', required=True)
args = vars(parser.parse_args())
logfile = args['filename']
duration = args['time']

print "Usage:\nepoch_feedreader_v0.5.py [output file] [duration of sample (s)]\n\nExample python epoch_feedreader_v0.2.py /tmp/converted_epoch_dates 60\n\n"

# Define command to be executed
c = [ '/opt/ale/bin/feed-reader', '-f', 'location']

# Monitor stdout, find timestamp, convert epoch to human readable and print to file

def TimeStamp():
    p = subprocess.Popen(c, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    while True:                                  #Read stdout and print each new line
       for line in iter(p.stdout.readline, b''):
         print(line.rstrip())                    #Print line
         sys.stdout.flush()
         if 'timestamp:' in line.rstrip():       #Look for string 'timestamp:' in stdout
           epoch_str = line.rstrip()
           epoch_str = line.strip("\t timestamp:")
           epoch_int = int(epoch_str)            # convert epoch.str to epoch.int
           utc_time = time.strftime('%Y-%m-%d %H:%M:%S', time.localtime(epoch_int))
           current_t = datetime.datetime.now()
           output = ('epoch %s for message published @%s converts to UTC %s' %(epoch_int, current_t, utc_time))
           outFile = open(logfile, "a")
           outFile.write(output)
           outFile.write("\n")
           outFile.close()

# Ue thread to time running of func TimeStamp
t  = Thread(target=TimeStamp)
t.daemon = True
t.start()
snooze = duration
time.sleep(snooze)