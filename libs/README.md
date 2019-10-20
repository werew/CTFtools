Collection of libc versions. Courtesy of (https://github.com/matrix1001/welpwn)

**How to run a binary with a different libc version:**

`LD_PRELOAD=./libc-2.19/64bit/libc.so.6 ./libc-2.19/64bit/ld.so.2 ./libc_info64`
