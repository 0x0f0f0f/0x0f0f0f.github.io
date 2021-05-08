@def title = "Building a Raspberry Pi 3B+ full keyboard handheld. Part 1"
@def published = "28 August 2019"
@def draft = false


Not really surprisingly, it is quite hard to get a mobile Linux handheld device in 2019.
You either have to build your own or try to get your hands on the (discontinued) [obscure ones](https://www.reddit.com/r/linux/comments/4biamr/a_list_of_handheldpocket_linux_computers/).
Would computer manufacturers sell you a device that lasts you 10 years? It is not really profitable from the seller's point of view.

Owning a Linux handheld computer can help you detox from harmful Social Media experiences;
using **FOSS** also means getting rid of bloatware or walled gardens like Android, iOS, MacOS or Windows. 
This can allow you to run top quality creative software without spending a cent, on hardware that is relatively really cheap!

Also, if you are a daily GNU/Linux user like me this will ease integration between your devices. I'm planning to use the same distro, Void Linux,
on every device I own. My desktop, my laptop and this handheld :)

Building a General Purpose Linux Handheld can be a fun and educative experience. You also end up with a device that 
your kids, parents, friends or sysadmin can enjoy for everyday tasks. 

This build is based on the [HyperPixel 4 & Raspberry Pi Handheld](https://www.thingiverse.com/thing:3209958) by Anthony Di Girolamo. I still have to 3D print the keys and assemble the case and electronics all together.


![Half assembled build](/assets/images/half.png)

## Features

Things that this device and smartphones can do:

* Taking notes
* Drawing
* Keeping track of a calendar and To-Do list
* Browse the internet, watch videos and listen to music
* Play games

On the roadmap:

* Take pictures and record videos
* Calls over the internet

Things the handheld can do but your smartphone cannot do very well:

* Use USB devices like a **gamepad, full size keyboards, Wi-Fi antennas**, 
* Plug the Pi to an **external HDMI screen** and use it like a media center or **game console emulator**.
* Switch between **multiple Free and Open Source operating systems** by simply swapping the memory card.
* Running a **modern kernel** and operating system. Android smartphones, for example run an outdated 3.x kernel with a bulky Java runtime.
* By default, **YOUR DATA IS YOURS AND NEVER LEAVES YOUR DEVICE**. It also means that synchronizing files between your devices is amazing with just ssh+git: you don't need an external cloud anymore.
* `root` access out of the box. **You can customize everything**.
* Having the choice between dozens of high quality **both simple and advanced Desktop Environments**
* Run hundreds of **programs you can read and edit**, malware-free user friendly **GUI apps**
* Run dozens of command line **power tools** and **window managers**
* Run **sandboxed desktop apps** with **flatpak**

Things the RPI Handheld cannot do (yet!) but a smartphone can do:

* Phone calls, SMS and data connectivity

By now the build has only the default Raspberry Pi 3 connectivity methods: WiFi and Bluetooth.
When you are on the go you can set up an external, portable 4G Hotspot. 
You should be able to use any portable mobile data WiFi hotspot or smartphone.

# Hardware

![Soldering and testing the keyboard](/assets/images/board01.png)

* Hyperpixel 4: 60FPS, 800x480 4 Inch touch screen display
* Raspberry Pi Model 3 B+ (Pi 4 needs a case redesign)
* 3D Printed retro looking Case and frame.
* Full 60 keys qwerty keyboard controlled by a Teensy 3.2. Perfect for programming and using the command line.
* 5000 mAh battery regulated by an Adafruit powerboost.
* 3 usable USB and Ethernet ports 

I'm building my DIY Linux Handheld basing on Anthony Di Girolamo's design and keyboard: [HyperPixel Handheld](https://www.thingiverse.com/thing:3209958) 
and [Teensy Thumb Board](https://hackaday.io/project/162281-teensy-thumb-keyboard)

I've got the Teensy Thumb Board PCB from Anthony's [tindie page](https://www.tindie.com/products/anthonysavatar/teensy-thumb-keyboard-pcb-only).
The thumb keyboard PCB was that magical piece that was missing to create an usable device.
Single board computers, 3d printed cases and touch displays are already widely available,
nothing though can be as smooth as using a full layout QWERTY keyboard when using an UNIX interface.
 
Building and soldering the keyboard can also be a good exercise for electronics beginners thanks to through hole soldering. 

![Half assembled build](/assets/images/running.png)

## Drivers

Pimoroni open sourced the Hyperpixel 4 Display [driver](https://github.com/pimoroni/hyperpixel4) on Github.
To install it on Void Linux I had to compile and install the [BCM2835 library](http://www.airspayce.com/mikem/bcm2835/), then
I had to compile, configure and install the driver manually. To reproduce the build on your Raspberry:

* Download the BCM2835 Library, build it and install it with
```sh
./configure
make
sudo make install
```

* Download the Pimoroni Hyperpixel 4 driver, `cd` into the `src/` directory and build it with
```sh
make build
# make init OUT OF DATE! new init is written in python
```

* *UPDATE!* Pimoroni updated the driver with new scripts written in python.
You will need the `python3`, `python3-devel` and `python3-pip` packages installed.

```sh
sudo xbps-install -Su python3 python3-devel python3-pip
```

* Now install the python library for accessing the GPIO pins, needed by the hyperpixel init script

```sh
sudo pip install RPi.GPIO
```

* If compiled successfully, cd back into the hyperpixel4 directory and install the driver and init program with
```sh
cd ..
cp src/hyperpixel4.dtbo /boot/overlays/
cp dist/hyperpixel4-init /usr/local/bin
```

* To initialize the display at boot time add a line containing `hyperpixel4-init` to `/etc/rc.local`.
* Copy the boot CONFIG_LINES from `install.sh` file in the Hyperpixel4 Driver repository to `/boot/config.txt`. Remove the quotes
* To enable rotation change the config line `dtoverlay=hyperpixel4` to `dtoverlay=hyperpixel4:rotate`
* To rotate the screen 180 deg. change the config line `display_rotate=3` to `display_rotate=1`

Calibrating the touchscreen was a bit more tedious. I had to open an [issue](https://github.com/pimoroni/hyperpixel4/issues/22) on the Hyperpixel driver repository. (shout out to [Francesco149](https://github.com/Francesco149) for helping me calibrate the touch display):

```sh
# install evdev driver and xinput_calibrator
sudo xbps-install -S xf86-input-evdev xinput_calibrator xinput
# create xorg config folder
sudo mkdir /etc/X11/xorg.conf.d/
# enable 10-evdev.conf
sudo cp /usr/share/X11/xorg.conf.d/10-evdev.conf /etc/X11/xorg.conf.d/
# list input devices and remember the id number next to "Goodix Capacitive Touchscreen"
xinput list
# now calibrate the touchscreen and save the config to a file. 
# replace HYPERPIXEL_ID with the number you found in the previous step
xinput_calibrator --misclick 0 --device HYPERPIXEL_ID > 99-calibration.conf.temp
# if the display was calibrated correctly, open the config file 
# in a text editor and remove the leading lines until the one beginning with "Section"
# and remember to save the file
nano 99-calibration.conf.temp 
# move the configuration file under its correct directory
sudo mv 99-calibration.conf.temp /etc/X11/xorg.conf.d/99-calibration.conf
```

You can test the calibration by restarting Xorg or rebooting the Pi.
Xorg will crash if you forget to remove the instructions from `99-calibration.conf.temp`


# Operating Systems

The Raspberry Pi (so the Raspberry Linux Handheld) can run a variety of  Operating Systems that provide great, smooth and secure daily usage experiences.

* [void linux](https://voidlinux.org) - [reddit community](https://reddit.com/r/voidlinux)
* [alpine linux](https://alpinelinux.org/) - [reddit community](https://old.reddit.com/r/AlpineLinux/)
* [freebsd](https://www.freebsd.org/) - [reddit community](https://old.reddit.com/r/freebsd)
* [openbsd](https://www.openbsd.org/) - [reddit community](https://reddit.com/r/openbsd)

# Follow up 

In the next posts I'll:

* Show the finished build
* Talk about software you can run on the handheld
* Add the official RPI camera, a speaker and a microphone
