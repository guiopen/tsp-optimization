## Taming the Heat: A Deep Dive into Trimui Smart Pro CPU Frequency Control

This guide delves into the Trimui Smart Pro's CPU frequency control, exploring its quirks, features, and the reasons behind its heat generation. More importantly, you'll learn how to optimize it for a cooler and more enjoyable experience.

### 1. Why Does the Device Run Hot?

Two main factors contribute to the perceived heat:

**1.1. Efficient Heat Dissipation:** The Trimui Smart Pro utilizes thermal pads connected to a copper sheet within its casing. This design, unlike those found in competitors, prioritizes efficient heat dissipation. While it might feel hotter to the touch due to the spread of heat, the device is actually running cooler internally.

**1.2. Aggressive Clock Speeds:** The real culprit lies in the Trimui Smart Pro's default clock speeds. The device utilizes an A133 Plus chip, an overclocked version of the standard A133. While the original A133 reaches up to 1600MHz, the Plus version pushes it to 1800MHz. Trimui takes it a step further, overclocking it to 2000MHz. This provides a performance boost for demanding games, but at a cost. Performance scales linearly with clock speed, but heat and energy consumption increase exponentially.

This trade-off seems acceptable for a performance gain, but the problem arises from the default configuration of some emulators. They often maintain a near-constant 2GHz frequency, even when the game doesn't demand it. This leads to excessive battery drain and a noticeably hot device. Fortunately, there's an easy fix, but first, let's understand how the Trimui Smart Pro manages its CPU frequency and the tools at our disposal.

### 2. Taking Control: cpufreq.sh Files

The Trimui Smart Pro offers two methods for controlling CPU frequency: the FN button and cpufreq.sh files. The FN button method, plagued with issues discussed later in secion 6, is not recommended. We'll focus on the more reliable cpufreq.sh files.

Within the Trimui Smart Pro's SD card package, under the "Emus" folder, each emulator has a corresponding cpufreq.sh file. This script, executed upon launching a game, tweaks the CPU frequencies for that specific emulator. While the concept is sound, the default configurations are often illogical.

Take the original Game Boy emulator script, for example:

```
echo ondemand > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
echo 1008000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
```

This script sets the governor to "ondemand" and the minimum frequency to 1008MHz. This is counterintuitive. The "ondemand" governor dynamically adjusts frequency based on demand. Setting a minimum frequency of 1008MHz when most Game Boy games run smoothly at 400-600MHz leads to unnecessary battery drain. While this might not be significant on lower-end systems, it becomes problematic with demanding platforms like the N64 and PSP.

Let's examine the default PSP script:

```
echo performance > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
echo 1418000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
```

This script sets the governor to "performance" and the minimum frequency to 1418MHz. However, the "performance" governor disregards the minimum frequency setting, forcing the device to run at its maximum clock speed of 2000MHz. This means even simple games like Tetris will run at 2000MHz, leading to excessive heat and rapid battery depletion.

As evident, the default cpufreq.sh scripts are far from optimal. The solution lies in editing these files. Before we delve into recommendations, let's understand the governors and frequency limits, empowering you to customize the scripts for your specific needs.

### 3. Understanding Governors and Frequency Limits

**Frequency Limits:**

Minimum and maximum frequency limits dictate the allowable range for the CPU frequency. For instance, setting a minimum of 800MHz and a maximum of 1800MHz allows the CPU to operate at any frequency within that range. However, the actual frequency selection is determined by the governor.

**Governors:**

* **The Bad:**
    * **performance:** Locks the CPU at the highest available frequency, ignoring actual demand and leading to unnecessary heat and battery drain.
    * **powersave:**  Locks the CPU at the lowest available frequency, potentially causing performance issues in demanding games.
    * **userspace:**  Allows programs with root access to control frequency, but is irrelevant in our context.

* **The "Could Be Good":**
    * **schedutil:**  Lets the CPU decide the ideal frequency. While effective more expensive CPUs like intel, amd and qualcom offerings, it's unreliable on the Trimui Smart Pro's poor Allwinner chip.
    * **interactive:**  Scales frequency drastically based on usage. Suitable for UI interactions, but less ideal for long and consistent like gaming.

* **The Actually Good:**
    * **ondemand:**  Dynamically adjusts frequency based on demand with a performance bias, preventing frame drops even with sudden spikes in CPU usage.
    * **conservative:**  Similar to "ondemand" but with a power-saving bias. Suitable for less demanding platforms where sudden spikes in CPU usage are less likely to ocurr.

### 4. Recommended Configurations

**General Use (balanded profile):**

```
echo ondemand > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
echo 408000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
echo 1608000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq
```

This configuration utilizes the "ondemand" governor, sets the minimum frequency to the lowest possible value (408MHz), and limits the maximum frequency to 1608MHz. This strikes a balance between performance and power consumption, ensuring smooth gameplay for most games while preventing excessive heat.

**Older Platforms (powersave profile):**

```
echo conservative > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
echo 408000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
echo 1608000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq
```

This configuration is identical to the previous one but utilizes the "conservative" governor for increased power savings. This is suitable for older platforms where the power-saving bias won't significantly impact gameplay.

**Demanding Emulation (performance profile):**

```
echo ondemand > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
echo 600000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
echo 1800000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq
```

This configuration increases the maximum frequency limit to 1800MHz for a performance boost in more demanding games. However, it's important to note that this will increase heat generation and battery consumption more then it's increase in performance..

**Important:** Avoid setting the maximum frequency to 2000MHz. This overclocked frequency is outside the CPU's supported range and offers minimal performance gains while significantly increasing device's temperature.

### 5. Limitations: Shared Frequency Policy

While exploring ways to optimize the Trimui Smart Pro's thermal performance, I encountered a significant hurdle: a shared frequency policy across all CPU cores. This quirk sets it apart from typical Linux systems and imposes limitations on our ability to fine-tune its performance.

In a conventional Linux environment, each CPU core operates as an independent unit. This allows for granular control over individual core frequencies, governors, and even the ability to disable unused cores entirely. For instance, if a task demands maximum performance from a single core, the system intelligently ramps up the frequency of that specific core while keeping the others at lower frequencies, conserving energy and minimizing heat.

However, the Trimui Smart Pro adopts a different approach. All four CPU cores are bound by a shared frequency policy. This means any change in frequency or governor setting applied to one core is automatically mirrored across all cores, regardless of their individual workloads. If one core, due to high demand, scales up to 1800MHz, the remaining three cores will also jump to 1800MHz, even if they are sitting idle. This inherent inefficiency leads to unnecessary energy consumption and increased heat generation.

Adding to the frustration, this shared policy extends even to "disabled" cores. While we can technically set a core's online status to "0," effectively preventing it from executing tasks, it doesn't translate to a complete shutdown. The core remains in an active state, continuing to draw power and contribute to heat generation, despite being unused.

This limitation significantly restricts our ability to optimize the system's thermal performance. We are unable to fine-tune individual core frequencies or leverage core disabling as a means to reduce heat. Our only recourse is to apply global changes to the frequency limits and governor, affecting all cores simultaneously.

Whether this shared frequency policy stems from a software limitation or an inherent hardware constraint remains unclear. However, should a future update address this quirk, it would unlock a significant opportunity for enhancing the Trimui Smart Pro's energy efficiency and thermal management. 


### 6. Beware of FN Key Profiles

While the Trimui Smart Pro offers FN key profiles for power saving and performance, they are riddled with bugs and should be avoided.

**Performance Mode Bugs:**

* **Sleep Malfunction:**  Engaging sleep mode with performance mode active prevents the device from entering a low-power state. This can lead to overheating, potentially damaging the device if left in a pocket or confined space.
* **Frequency Limit Override:**  Even with the FN key switched off, simply having performance mode enabled in the FN key settings can override custom frequency limits, letting the device to run at 2000MHz in demanding games.

**Powersave Mode:**

While no specific bugs have been identified with powersave mode, its reliability is questionable given the issues with performance mode.

**Recommendation:**  Disable both performance and powersave modes in the FN key settings and rely solely on the cpufreq.sh files for frequency control.

### 7. Implementation Instructions

To implement these recommendations:

1. **Download:** Clone this repository or download the zip file containing the Emus folder with the modified cpufreq.sh scripts.

2. **Access SD Card:** Connect the Trimui Smart Pro's SD card to your computer.

3. **Replace Scripts:** Copy the Emus folder of this repository and paste it in the root of your device SD card, when asked to merge or replace the files, accept for everything. This will copy the modified cpufreq.sh file over the original ones. By default the modified cpufreq.sh file will use the balanced profile, if you want to use the powersave or performance profiles you can copy the example scripts from this repository into the emulator you want, delete the cpufreq.sh file already there and rename the example to cpufreq.sh.

4. **Reinsert and Enjoy:** Reinsert the SD card into the Trimui Smart Pro and restart the device.

By following these steps, you can take control of your Trimui Smart Pro's CPU frequency, reducing heat generation, extending battery life, and enjoying a smoother gaming experience.
