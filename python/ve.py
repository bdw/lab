#!/usr/bin/env python
import argparse
import os
import os.path
import sys
import subprocess
import shutil

try:
    import virtualenv
except ImportError:
    print("virtualenv could not be imported, aborting")
    quit(1)

HOME_DIR = os.path.join(os.path.expanduser('~'), '.ve')
if not os.path.isdir(HOME_DIR):
    try:
        os.mkdir(HOME_DIR)
    except OSError:
        print("Could not make ve directory, aborting")
        quit(1)

parser = argparse.ArgumentParser(description='virtualenv helper')
parser.add_argument('-m', '--make', action='store_const', const=True)
parser.add_argument('-d', '--delete', action='store_const', const=True)
parser.add_argument('name', nargs='?')

args = parser.parse_args(sys.argv[1:])

if not args.name:
    print("Available virtualenvs:")
    names = [name for name in os.listdir(HOME_DIR)
             if os.path.isdir(os.path.join(HOME_DIR, name))]
    border = '-' * (reduce(max, map(len, names), 0) + 2)
    print(border)
    for name in names:
        print(' ' + name)
    print(border)
    quit(0)
DEST_DIR = os.path.join(HOME_DIR, args.name)
if args.make:
    print("Making virtualenv at: {0}".format(DEST_DIR))
    virtualenv.create_environment(DEST_DIR, clear=True)
elif not os.path.isdir(DEST_DIR):
    print("virtualenv at {0} does not exist".format(DEST_DIR))
    quit(1)
elif args.delete:
    print("Removing virtualenv at: {0}".format(DEST_DIR))
    shutil.rmtree(DEST_DIR)
else:
    rcfile = os.path.join(DEST_DIR, 'bin', 'activate')
    os.execvp('bash', ['bash', '--rcfile', rcfile])
