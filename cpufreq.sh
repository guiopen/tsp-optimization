#!/bin/sh
# 1 - disabling unecessary cpu core
echo 1 > /sys/devices/system/cpu/cpu0/online
echo 1 > /sys/devices/system/cpu/cpu1/online
echo 1 > /sys/devices/system/cpu/cpu2/online
echo 0 > /sys/devices/system/cpu/cpu3/online

# 2 - tuning cpu cores
echo ondemand > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
echo 408000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
echo 1800000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq
