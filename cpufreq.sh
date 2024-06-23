#!/bin/sh
# 1 - disabling unecessary cpu cores
echo 1 > /sys/devices/system/cpu/cpu0/online
echo 1 > /sys/devices/system/cpu/cpu1/online
echo 0 > /sys/devices/system/cpu/cpu3/online
echo 0 > /sys/devices/system/cpu/cpu2/online

# 2 - tuning main cpu core
echo ondemand > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
echo 408000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
echo 1800000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq

# 3 - tuning secondary cpu core
echo ondemand > /sys/devices/system/cpu/cpu1/cpufreq/scaling_governor
echo 408000 > /sys/devices/system/cpu/cpu1/cpufreq/scaling_min_freq
echo 1200000 > /sys/devices/system/cpu/cpu1/cpufreq/scaling_max_freq
