#!/usr/bin/env python3

from pwn import *

# ----------- Configuration ------------

# Configure accordingly
BINARY = './target'
HOST, PORT = 'exaplehost', 42
LIBC = None # Example: './libc-2.27.so'
LD   = None # Example: './ld.so.2' 

# Pwntools context
context.arch = 'amd64'
context.terminal = ['tmux', 'new-window']
context.aslr = None

# Load binaries
elf  = ELF(BINARY)
libc = ELF(LIBC) if LIBC else None

# Breakpoints
global_breakpoints=[]

# ----------- Helpers ------------

def get_base_address(proc):
    return int(open("/proc/{}/maps".format(proc.pid), 'rb').readlines()[0].split('-')[0], 16)

def attach(breakpoints):
    script = "handle SIGALRM ignore\n"
    PIE = get_base_address(p)
    script += "set $_base = 0x{:x}\n".format(PIE)
    breakpoints.extend(global_breakpoints)
    for bp in breakpoints:
        script += "b *0x%x\n"%(PIE+bp)
    gdb.attach(p, gdbscript=script)

# ----------- Launchers ------------

def run_debug(binary, breakpoints=[], libc=None, ld=None):
    PIE = get_base_address(p)
    script = "handle SIGALRM ignore\n"
    script += "set $_base = 0x{:x}\n".format(PIE)
    breakpoints.extend(global_breakpoints)
    for bp in breakpoints:
        script += "b *0x%x\n"%(PIE+bp)

    if libc:
        log.info('Running preloading libc "%s"' % libc)
        if ld:
            return gdb.debug([ld, binary], env={'LD_PRELOAD', libc})
        else:
            log.warn('Using custom libc, however no loader provided. This may cause a crash')
            return gdb.debug([binary], env={'LD_PRELOAD', libc})

    return gdb.debug(binary)

def run_plain(binary, libc=None, ld=None):
    if libc:
        log.info('Running preloading libc "%s"' % libc)
        if ld:
            return process([ld, binary], env={'LD_PRELOAD', libc})
        else:
            log.warn('Using custom libc, however no loader provided. This may cause a crash')
            return process([binary], env={'LD_PRELOAD', libc})

    return process(binary)

def start():
    if args.REMOTE:
        log.info("REMOTE PROCESS")
        return remote(HOST, PORT)

    elif args.DEBUG:
        log.info("LOCAL PROCESS (DEBUG)")
        return run_debug(BINARY, libc=LIBC, ld=LD)

    else:
        log.info("LOCAL PROCESS")
        return run_plain(BINARY, libc=LIBC, ld=LD)

# ----------- Examples -------------

def add(content):
    p.sendlineafter('> ', '1')
    p.sendlineafter('> ', content)

def show():
    p.sendlineafter('> ', '2')

def free():
    p.sendlineafter('> ', '3')



# ----------- Main Logic ------------
p = start()

p.interactive()

