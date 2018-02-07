#!/usr/bin/env python

import r2pipe
import argparse

parser = argparse.ArgumentParser(description='Generate r2 zignatures for given executables')



parser.add_argument('exe', metavar='exe', nargs='+', help='one or more target executables')
parser.add_argument('-o', metavar='zfile', nargs='?', default='r2zignatures.sdb', 
                    help="""where to store the signarutes (merge if file exists).
                    Default is r2zignatures.sdb""")
parser.add_argument('-c', metavar='commands',nargs='?', help="""commands to run before genarating 
                    signatures (you may want to set some env vars and do some anal)""")



args = parser.parse_args()
for exe in args.exe:
    print("Generating zignatures for: %s" % exe);
    r2 = r2pipe.open(exe, ['-e io.cache=true'])
    if args.c:
        r2.cmd(args.c)
    r2.cmd('zg')
    r2.cmd('zos %s' % args.o)






