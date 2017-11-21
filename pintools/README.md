### A small collection of [pin](https://software.intel.com/en-us/articles/pin-a-dynamic-binary-instrumentation-tool) tools for various analysis tasks

Here there is a small descriptions of each tool. More infos can be
found inside the tools.

#### coverage.cpp

Trace the execution of a program. 
Traces can be taken at two granularity levels: funtions (default), basic blocks (option -b).

Example tracing basic blocks: `../../../pin -t obj-intel64/coverage.so -o output -b -- ./myprog`

You can add/remove the paths of dynamic loaded libs to `path_to_blacklist` (see code) to untrace/trace them.

Pinpointing using traces:
```
# Don't forget to disable ASLR
echo 0 | sudo tee /proc/sys/kernel/randomize_va_space

# Generate two traces
../../../pin -t obj-intel64/coverage.so -o trace1 -- ./myprog                # base execution
../../../pin -t obj-intel64/coverage.so -o trace2 -- ./myprog -some-option 

# Prune traces (Optional)
sort trace1 | uniq > out1
sort trace2 | uniq > out2

# Find the differences
./diff_traces.py out1 out2

```

