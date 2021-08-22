`coverage.cpp` traces the execution of a program. 
Traces can be taken at two granularity levels: funtions (default), basic blocks (option -b).

Example tracing basic blocks: `../../../pin -t obj-intel64/coverage.so -o output -b -- ./myprog`

You can add/remove the paths of dynamic loaded libs to `path_to_blacklist` (see code) to untrace/trace them.

Tips: 
```
# It can be useful to disable ASLR
echo 0 | sudo tee /proc/sys/kernel/randomize_va_space
```

