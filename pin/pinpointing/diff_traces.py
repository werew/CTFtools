#!/usr/bin/env python
"""
This is modified version of the script "inout.py"
at: https://drive.google.com/drive/u/0/folders/0B5y5AGVPzpIOd2s3aUJRc2VJX0E

Thanks gynvael
"""

import sys

if len(sys.argv) < 3:
    print("Usage: %s base_trace target_trace" % sys.argv[0])
    sys.exit(1)

def load(fname, tab):
  ln = open(fname,"r").read().split("\n")
  for k in ln:
    if len(k) == 0:
      continue
    tab[k] = True

base   = {}
target = {}

load(sys.argv[1], base)
load(sys.argv[2], target)

for i in target.keys():
  if i in base:
    continue
  print i



