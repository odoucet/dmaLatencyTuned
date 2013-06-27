dmaLatencyTuned
===============
Power consumption is based on C-States.
http://pm-blog.yarda.eu/2011/10/deeper-c-states-and-increased-latency.html

You can adjust kernel response time - and accordingly CPU consumption - by writing to /dev/cpu_dma_latency

This tool monitors /proc/stat and write to this file to get the most effective value : 
if CPU is idle, allow C6/C7, and then change based on load.
When CPU is heavily used, stay in C0

To see C-States / dma_latency value relationship : 
cat /sys/devices/system/cpu/cpu0/cpuidle/state*/{name,latency}