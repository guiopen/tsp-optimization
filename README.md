# tsp-optimization
This is an in-depth guide for everything you can do in software to reduce temperature and improve battery life of the Trimui Smart Pro handheld with minimal-to-zero performance loss. Also, it will explain all of its quirks and serve as a documentation for cpu frequency control in portable gaming handhelds

This heat has two main causes:

 **1 - Better heat dissipation:** Unlike competitors like the RG35XXH, the TrimUI uses thermal pads connected to a copper sheet in the casing. This gives the impression that it heats up more, but what actually happens is that it dissipates heat more efficiently. It just feels hotter because the heat is spreading, but in reality, it's running cooler.

 **2 - Aggressive clock speeds:** The other reason, and the one we'll address here, is the excessive clock speed increase that the TrimUI uses by default. The A133 Plus chip that trimui uses is already an overcloked version of the normal a133, the origina can reach up to 1600MHz, the Plus version up to 1800mhz, and even trimui overclocked it even more so it can reach up to 2000MHz. This is good for giving an extra boost when running demanding games, but the problem is that while performance scales linearly, heat and energy consumption increase exponentially. So, we have a small performance gain for a huge increase in energy consumption.

Still, since we're gaining performance, this trade-off is worth it, right? Well, in theory, yes, but in practice, some emulators like the PSP emulator or the Fn key's performance mode are configured to stay at 2GHz all the time, even when games don't need that much power to run smoothly, draining its precious battery and leaving your hands burning.

To improve this issue, I created a custom cpufreq.sh file to replace the default ones that come with the emulators:

The first part of this file disable the fourth cpu core of the a133plus, because most present in trimui emulators are singe-threaded, a couple of them like PPSSPP can use more cores, but even then the 4th core is berely used. Disabling him can save energy without a performance impact. You can still limit it to 2 CPU cores for playstation and below to save energy without a performance impact.

```
echo 1 > /sys/devices/system/cpu/cpu0/online
echo 1 > /sys/devices/system/cpu/cpu1/online
echo 1 > /sys/devices/system/cpu/cpu3/online
echo 0 > /sys/devices/system/cpu/cpu2/online
```

The second part involves tuning the CPU cores. The clock limit has been reduced from 2000MHz to 1608MHz, which is the maximum frequency of the original a133 chip. Additionally, the minimum frequency has been set to 408MHz, and the CPU governor has been set to "ondemand." This configuration allows the clock speed to automatically adjust between 408MHz and 1608MHz based on the requirements of each game, loosig a little bit of performance but significantly reducing heat generation.

```
echo ondemand > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
echo 408000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
echo 1608000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq
```

For increased performance, you can raise the CPU limit from 1608MHz to 1800MHz. This provides nearly the same performance as the stock settings but with a noticeable improvement in temperatures and battery life. However, it does represent a less favorable trade-off compared to 1608MHz, so only increase the limit if you need the extra performance:

```
echo ondemand > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
echo 408000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
echo 1800000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq
```

If you need to squeeze every last drop of performance out of the CPU, you can swap the second part for the following configuration. This unlocks the CPU limit, raising it to 2000MHz. However, this is not recommended as it exceeds the chip's designed specifications. Additionally, the performance gains are minimal compared to the increased heat generation and battery usage:

```
echo ondemand > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
echo 408000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
echo 2000000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq
```

To make the changes to the TrimUI Smart Pro, clone this repository or download the zip file, access the TrimUI Smart Pro's SD card, open the terminal at the root of the card and, in Linux, run the following command:

```
find . -type f -name "cpufreq.sh" -exec cp /path/to/file/cpufreq.sh {} \;
```
/path/to/file should be replaced with the actual path to the cpufreq.sh file you downloaded from this repository. This command will overwrite all default CPU frequency scaling scripts within the emulators with the modified version.

If you are using an operating system other than Linux, you can manually replace the stock scripts in the emulators with this one. Alternatively, you can use a program or script compatible with your operating system to automate this process.

Afterward, reinsert the SD card into the handheld and restart or power on the device. Enjoy!

Note: The scripts will be temporarily disabled if you use the performance or power-saving modes activated with the Fn key. To re-enable them, simply disable these modes and restart the device.

**Roadmap:**
 - Tune the scripts per emulator
 - Add a way to easily apply the scripts in windows and Macos
 - Make vídeos comparing the performance and temperatures
