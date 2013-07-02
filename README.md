dmaLatencyTuned
===============
Power consumption is based on C-States.
http://pm-blog.yarda.eu/2011/10/deeper-c-states-and-increased-latency.html

You can adjust kernel response time - and accordingly CPU consumption - by writing to /dev/cpu_dma_latency

Why this tool ? 
---------------
By experience, default timings are too aggressive in current kernel, and CPU goes to C6-state too often, leading to
a less responsive server. I personnally found a 40% difference performance on some benchmarks !
I wrote this tool after exposing my problem on kernel mailing list here : http://comments.gmane.org/gmane.linux.kernel/1425277

Performance comparison
----------------------
See for yourself : 
![Benchmark](http://tof.canardpc.com/view/b8d2e869-f92b-46c8-969b-b3c97262d7e5.jpg)

How it works
------------
This tool monitors /proc/stat and write to this file to get the most effective value : 
- if CPU is idle, allow C6/C7, and then change based on load.
- When CPU is heavily used, stay in C0

To see C-States / dma_latency value relationship : 

```
cat /sys/devices/system/cpu/cpu0/cpuidle/state*/{name,latency}
```

