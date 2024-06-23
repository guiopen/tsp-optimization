# tsp-optimization
Trimui Smart Pro, for its price, is good on a lot of aspects, but one of the problems that scares buyers away is the excessive heat reported by users. 

This heat has two main causes:

 **1 - Better heat dissipation:** Unlike competitors like the RG35XXH, the TrimUI uses thermal pads connected to a copper sheet in the casing. This gives the impression that it heats up more, but what actually happens is that it dissipates heat more efficiently. It just feels hotter because the heat is spreading, but in reality, it's running cooler.

 **2 - Aggressive clock speeds:** The other reason, and the one we'll address here, is the excessive clock speed increase that the TrimUI uses by default. The A133 Plus can reach up to 1800MHz, and even 2000MHz with the overclock that the TrimUI applies. This is good for giving an extra boost when running demanding games, but the problem is that while performance scales linearly, heat and energy consumption increase exponentially. So, we have a small performance gain for a huge increase in energy consumption.

Still, since we're gaining performance, this trade-off is worth it, right? Well, in theory, yes, but in practice, some emulators like the PSP emulator or the Fn key's performance mode are configured to stay at 2GHz all the time, even when games don't need that much power to run smoothly, draining its precious battery and leaving your hands burning.

To improve this issue, I created a custom cpufreq.sh file to replace the default ones that come with the emulators:

The first part of this file takes advantage of a feature common to all emulators present in the TrimUI: they are single-threaded, meaning the entire game is emulated on a single core. However, the A133P has 4 cores. We can disable 2 of the 4 cores to save energy because they are not used during games. We leave 2 cores enabled instead of just 1 to be able to run other system functions on a separate core, without stealing performance from our main gaming core.

```
# 1 - disabling unnecessary cpu cores
echo 1 > /sys/devices/system/cpu/cpu0/online
echo 1 > /sys/devices/system/cpu/cpu1/online
echo 0 > /sys/devices/system/cpu/cpu3/online
echo 0 > /sys/devices/system/cpu/cpu2/online
```

The second part is the tuning of the main core, responsible for running the games. Here the clock limit has been reduced from 2000MHz to 1800MHz, which is the maximum recommended for the A133P chip. We also set the minimum frequency to 408MHz and the CPU governor to ondemand. This way the clock will vary from 408 to 1800 automatically depending on the needs of each game.

```
# 2 - tuning main cpu core
echo ondemand > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
echo 408000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
echo 1800000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq
```

The third part adjusts the frequencies of the secondary core, but since the games will not run here, we can leave the clock limit lower:

```
# 3 - tuning secondary cpu core
echo ondemand > /sys/devices/system/cpu/cpu1/cpufreq/scaling_governor
echo 408000 > /sys/devices/system/cpu/cpu1/cpufreq/scaling_min_freq
echo 1200000 > /sys/devices/system/cpu/cpu1/cpufreq/scaling_max_freq
```

Finally, if anyone feels the need to squeeze every last drop of performance out of the main core, they can swap the second part for this, unlocking the CPU limit up to 2000MHz, even if the performance-energy tradeoff is no longer worth it:

```
# 2 - tuning main cpu core
echo ondemand > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
echo 408000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
echo 2000000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq
```

To make the changes to the TrimUI Smart Pro, clone this repository or download the zip file, access the TrimUI Smart Pro's SD card, open the terminal at the root of the card and, in Linux, run the following command:

```
find . -type f -name "cpufreq.sh" -exec cp /path/to/file/cpufreq.sh {} \;
```
`/path/to/file` should be the path to the cpufreq.sh file downloaded from this repository. This command will replace all default cpufreq files in the emulators with the modified version. After that, just reinsert the card into the TrimUI Smart Pro and play to feel the difference :)
(If you are using another operating system you need to search how to replace files there)
