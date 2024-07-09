# tsp-optimization
This is an in-depth guide for anyone interested more about the Trimui Smart Pro CPU frequency control. Here you will learn about all of its quirks, features, why the device is so hot and how to improve it.

1 - Why the device runs hot?

The heat has two main causes:

 **1.1 - Better heat dissipation:** The first cause is not a real problem at all, but still is one of the reasons why the device feels so hot on the hand. Unlike competitors, the Trimui Smart Pro uses thermal pads connected to a copper sheet in the casing. This gives the impression that it heats up more, but what actually happens is that it dissipates heat more efficiently. It just feels hotter because the heat is spreading, but in reality, it's running cooler.

 **1.2 - Aggressive clock speeds:** The other reason, and where lies the real problem, is the excessive clock speeds that the TSP uses by default. The A133 Plus chip that trimui uses is already an overcloked version of the normal a133, the original can reach up to 1800MHz, the Plus version up to 1800mhz, and Trimui overclocked it even more so it can reach up to 2000MHz. This is good for giving an extra boost when running demanding games, but the problem is that while performance scales linearly, heat and energy consumption increase exponentially. So, we have a small performance gain for a huge increase in energy consumption and heat generation each time we increase the clocks.

Still, since we're gaining performance, this trade-off is worth it, right? Well, in theory, yes, but in practice, some emulators are configured to stay at 2GHz (or close to it) all the time, even when games don't need that much power to run smoothly, draining its precious battery and leaving your hands burning. But dont worry, its very easy to fix this, but first we shold understand how the TSP controls its frequency and what are the options we have in our hands to manage this.

2 - What CAN we do?

We have two ways of controlling the TSP cpu frequency: FN button and cpufreq.sh files. The FN button way has a lot of problems which we well talk about later in the section 4, and it is not recommended, so we will use the cpufreq.sh files for this

Inside the sd card package of the TSP, in the Emus folder, we can notice that each one of the emulators has a cpufreq.sh file, this is a script that is executed every time we start a game, and is responsible tweaking the frequencies our cpu can achieve per emulator, while the idea is good the execution is not, and in the default files we can encounter a lot of strange configuratios, like the script for the original gameboy:

```
echo ondemand > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
echo 1008000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
```

This script set the governor to ondemand and the minimum frequency to 1008 mhz, which dosent make sense, as the ondemand governor will automatically adjust the frequency as needed, so if you need 1200 mhz to run the game at full speed, then the cpu will scale to at least 1.2ghz, on the contrary, if you can run the game at 400mhz, then the cpu will scale to at least 400 mhz, but because of this script the frequency will never go lower than 1008mhz, while most game boy games can run at 400-600mhz full speed, so limiting the minimum frequency only wasters battery, but in these lower end systems this dosent make a lot of difference because 1ghz is already low, and dosent consume much battery or generate much heat, the problem starts when we go to heavier plataforms like n64 and psp, lets take a look at the ṕsp as an example :

```
echo performance > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
echo 1418000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
```

These are the default launching settings for psp, here the governor is set to performance and the the minimum frequency is set to 1416 mhz, the thing is, the minimum frequency is completly ignored by the performance governor, which makes the device run at the maximul available clock, in the trimui smart pro this will be 2000 mhz, it dosent matter if you are running god of war or tetris, every psp game will be played at 2000 mhz, this will make your hands burn and quickly drain your battery life.

As you can see, the default cpufreq scripts that come with the Trimui Smart Pro are kinda bad and dosent make a lot of sense, so what we can do to improve it is to edit these files, but before i give you my recommendatios, i will talk a bit about the governors and the frequency limits so you can edit the scripts for you own usecase if needed. First, lets talk about the frequency limits.

The minumum and maximum frequency limits controls how low or how high the cpu frequency can go, so if set my miminum frequency to 800 mhz and my maximum frequency to 1800 mhz, the cpu could run at any value between and including these two, but they just set the limits, what actually decides the frequency is the governor, and here we have a lot of options, i will separate them in the ones that are bad, the ones that could be good, and the ones that are actually good.

3 - The governors
    3.1 - The bad ones: performance, powersave and userspace
        **performance:** What this one do is to always set the frequency to the highest available, so if we limit it to 1800 mhz like the example above, then whe cpu frequency will stay at 1800 mhz all the time, this is bad because the same emulator can run fairly different games with fairly different requirements, so if you are really running a game that needs these 1800 mhz, then you are running it at the ideal frequency here, no problems, but then you change to a less demanding game in the same emulator, you will still be using 1800 mhz, but you could run the game with much less, saving power and reducing heat.
        **powersave:** Similar to performance, but will set the cpu to lowest frequency available, in our example that would be 800 mhz, and its bad because even if some games can be run at the minimum frequency you have set for an emulator, other games wont achieve full speed unless your minimum frequency is too high, which then would cause unecessary heat and battery drain.
        **userspace:** This governor is actually not a governor, it just lets programs with root access to chose the frequency, in our case we dont have any program doing that, so it becomes useless.
    3.2 - The "could be good" ones: schedutil and interactive
        **shedutil:** This is the default governor for modern linux machines, and what it do is let the cpu automatically decide the ideal frequency itself instead of the kernel, and in more advanced cpus like intel, amd and qualcom, it works really well and provides super low latency in frequency swithiching, but in our case we have an underground allwinner chip designet for IOT, so it is not the smartest at deciging its own frequency and end up making worse decisions than the linux kernel.
        **interactive:** This governor is often used in smartphones, what it does is scale the frequency up and down drastically upon usage, lets say you are scrolling a page, then the frequency will go super high and will make the scrolling super smooth, but as soon as you stop it will scale down the frequencies a lot, saving energy. While this is a good choice for quick ui interactios, but gaming is a constant task, and we dont want the frequencies jumping up and down every time something happens, instead we perfer a less extreme frequency switching, providing a smoother gameplay and a more stable fps.
    3.3 - The actually good ones: ondemand and conservative
        **ondemand:** This is usually the best choide for most plataforms and is the default scheduler in this system, what is does is, like the schedutil and interactive governors, scale the frequency up and down according to the user needs, but unlike them, it is reliable and provides stable frequencies, it also has a bias for performance, lets say your games need 1200 mhz to run smoothly, then the ondemand governor will scale to 1400-1600 mhz for example. this is done to prevent frame drops when the game abruptly throws more enemies to render, o change the cenary, or anything that needs more power.
        **conservative:** This is very similar to ondemand, but has a bias for powersaving, so if the game needs 1200 mhz to run smoothly, then the conservative governor will set the frequency to 1200 mhz, saving more battery and reducing heat, but like he previous scenario, if the games abruptly needs more power, it will need to ramp up the frequency, but that has a latency cost and during this period the game will see frame drops  which mich hurt gameplay. For this reason, this governor wont work well on heavier plataforms like n64 and up, but is well suited to older consoles like the game boy, providing hours and hours of gameplay with minimal battery consumpion and beraly notiable heating. 

4 - My recommendations:
    For general use, you should use this:
        ```
        echo ondemand > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
        echo 408000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
        echo 1608000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq
        ```
    For the minimum frequency we are using 408 mhz, which is the lowest frequency you can get in the TSP, for the maximum we are using 1608 mhz, which is enough for almost all the games that we can run, like psp god of war or n64 ocarina of time, both of those will run smothly without frameskip, this frequency limit is a nice balance between power consumption and performance, and will prevent the device from heating too much. The ondemand governor will prevent frame drops and adjust well to each game requirements, and the 1608 mhz frequency limit will prevent its performance bias of going overboard. If you dont want to tinker to much, you can use this configuration for all your systems and you will be good.

    For older plataforms that are easier to emulate, you can use this:
        ```
        echo conservative > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
        echo 408000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
        echo 1608000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq
        ```
    
    It is the same as the previous script, but replacing the ondemand governor with conservative, so the clocks will be lower and the device will consume less energy, and for older plataforms the powersaving bias of this governor shouldnt be a problem, you can test it with your games and, if it works, use it for that plataform.

    For more demanding emulation, you can use this:
        ```
        echo ondemand > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
        echo 600000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
        echo 1800000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq
        ```

    Here we are increasing or maximum frequency limit to 1800 mhz, this will make the device heat a lot more and drain the battery faster, but could provide a smoother experience in games that were previously struggling, while still being a frequency supported by the cpu, you shouldn go any higher than that, setting the limit to 2000 mhz is not recommended as it is an overclock, that frequency is outside of the cpu supported range and will make the device heat a lot while providing very small performance benefits, so if you need more performance, stick to 1800 mhz if you can.

5 - What we CANT do?
    In my time with the trimui smart pro i have tried a lot of tricks that, in any normal linux system, should work without problems, but turns out that most of them were useless in this device due to a little quirk: shared frequency policy.

    In most of devices, each cpu core is independent of each other and act as a little cpu itself, so it can have its own frequency limits, governor and even be disabled if not needed, so that when we a using one core to the maximum, the system will ramp up the frequency of this core only, while keeping the frequency of the other unused cores lower, but on the Trimui Smart Pro that dont happen, each one of the four cpu cores here have their frequency and configurations shared to each other, so if one of the cores is being more utilized and ramps up its frequency to, lets say, 1800 mhz, then every core will also scale to 1800 mhz even if not being utilized, making it extremely inefficient. This limitation even affects disabled cores, so if we set the online state of the core from 1 to 0, it will not be utilized anymore, but will ramain active, using energy and heating up the device without shame.

    Because of this limitation, we cant finetune the frequencies per cpu core or disable some of them in the hope to reduce heat, everything we can do is tinker with the frequency limits and governor for all of them simultaniously. It isnt currently know if that is a software or hardware limitation, but if its resolved in future updates we will be seeing a gigantic improvement in energy efficiency.

6 - What should we be aware off?
    Now that everything is explained, we can talk about why we choose to control the frequency with the cpufreq files instead of the fn key profiles, and the reason is, the fn key profiles are totaly buggy and messes up

    The fn key powersave mode switches the governor to powersave, running the cpu at the minimum available frequencies, and the performance mode switches the governor to performance, running at a constant to 2000 mhz, so even if they were working it wouldnt be recommended, but what make its worse are the bugs

    The most dangerous bug is the sleep function with the performance mode turned on, normally when you press the power button the device is put into a low power state where it uses very little battery, but if you do this with the FN key to the right and performance mode enabled, the device will not enter this state and keep running at the maximum frequency possible, if you do that and put it in your pockets the device will burn, potentially damaging the battery, screen or its internal components, NEVER put it to sleep with performance mode turned on.

    Another bug is, even if the FN key is off (turned to the left), just having performance mode enabed in the settings is already enough to mess up with our scripts, it wont run at a consistent 2000 mhz if if it were turned on, but will complely ignore our maximum frequency limits, so the device will still run at 2000 in demanding games regarless of what we setted as our maximum frequency possible.

    There are no know bugs regarding the powersaving mode, but seeing how strange is the behaviour of the performance mode, its wouldnt be a surprise if the powersave mode is also infested with hidden bugs.

    For all these reasons, you shouldn use the powersave and performance mode, and should disable them in the FN key settings as just turning the fn key off is not enough.

7 - Instructions:

If you want to apply and test the suggestions made here, you can manually modify the cpufreq files inside the EMUS folder by copy-and-pasting the contend of the cpufreq files of this repository according to your needs.

Alternatvaly, you could replace every one of those files with the modified cpufreq.sh scripts containing my general recommendations:
    ```
    #!/bin/sh
    echo ondemand > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
    echo 408000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
    echo 1608000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq
    ```
To do this, clone this repository or download the zip file, access the TrimUI Smart Pro's SD card, open the terminal at the root of the card and, in Linux, run the following command:

```
find . -type f -name "cpufreq.sh" -exec cp /path/to/file/cpufreq.sh {} \;
```
/path/to/file should be replaced with the actual path to the cpufreq.sh file you downloaded from this repository. This command will overwrite all default CPU frequency scaling scripts within the emulators with the modified version.

If you are using an operating system other than Linux, you can manually replace the stock scripts in the emulators with this one. Alternatively, you can use a program or script compatible with your operating system to automate this process.

Afterward, reinsert the SD card into the handheld and restart or power on the device. Enjoy!

Note: The scripts will be temporarily disabled if you use the performance or power-saving modes activated with the Fn key. To re-enable them, simply disable these modes and restart the device.