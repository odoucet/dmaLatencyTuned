#!/bin/env php
<?php

/*****************
 * DMA Latency Tuned
 * Adjust /dev/cpu_dma_latency based on CPU load
 *
 * @author Olivier Doucet <olivier at oxeva dot fr>
 ***************/

// Interval chosen to update value (in seconds)
define('LOOPTIME', 10);

// if CPU > X, then disable all C-States
$latencyValues = array(
    //CPU% => value   (please order by CPU DESC)
    40     => 0,     // disable all (full speed)
    15     => 11,    // C1E state
    5      => 201,   // C6  state
);

$oldValues = array(
    'busy' => 0,
    'idle' => 0,
);

$currentLatency = -1;

// old that file descriptor 
$fp = fopen('/dev/cpu_dma_latency', 'w');
openlog('dmalatency', LOG_ODELAY, LOG_DAEMON);

while (true) {
    // Get new values
    $z = preg_match(
        '@cpu\s+([0-9]{1,}) ([0-9]{1,}) ([0-9]{1,}) ([0-9]{1,}) ([0-9]{1,})'.
        ' ([0-9]{1,}) ([0-9]{1,}) @',
        file_get_contents('/proc/stat'),
        $data
    );
    
    if (!$z) {
        // fail ... no infinite loop plz
        sleep(1);
        continue;
    }
    
    $newValues = array(
        'busy' => $data[1]+$data[2]+$data[3]+$data[5]+$data[6]+$data[7],
        'idle' => $data[4],
    );
    if ($oldValues['busy'] == 0) {
        // Wait
        $oldValues = $newValues;
        sleep(LOOPTIME);
        continue;
    }
    
    $busyPercent = ($newValues['busy'] - $oldValues['busy'])/
                   ($newValues['busy'] - $oldValues['busy']+$newValues['idle'] - $oldValues['idle'])
                   *100;
    printf("CPU Usage: %5.2f %%  \r", $busyPercent);
    
    // Do the stuff
    foreach ($latencyValues as $cpuUsage => $latencyNeeded) {
        if ($busyPercent >= $cpuUsage)
            break;
    }   
    
    if ($currentLatency != $latencyNeeded) {
        fwrite($fp, pack('i', $latencyNeeded));
        rewind($fp);
        syslog(LOG_NOTICE, 'DMA Latency changed from '.$currentLatency.' to '.$latencyNeeded.'');
        $currentLatency = $latencyNeeded;
    }
    
    $oldValues = $newValues;
    sleep(LOOPTIME);
}
closelog();
fclose($fp);
