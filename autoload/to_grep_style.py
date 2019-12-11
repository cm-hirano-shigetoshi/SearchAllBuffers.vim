#!/usr/bin/env python
import os
import sys

file_path = sys.argv[1]

try:
    i = 0
    line = sys.stdin.readline()
    while line:
        i += 1
        line = line.strip("\n")
        line = '{}:{}:{}'.format(file_path, i, line)
        print(line)
        line = sys.stdin.readline()
except BrokenPipeError:
    devnull = os.open(os.devnull, os.O_WRONLY)
    os.dup2(devnull, sys.stdout.fileno())
    sys.exit(1)
