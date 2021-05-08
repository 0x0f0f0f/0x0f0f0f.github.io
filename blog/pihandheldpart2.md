@def title = "Building a Raspberry Pi 3B+ full keyboard handheld. Part 2"
@def published = "27 September 2019"

{{post_header}}


After the [first write-up](/blog/pihandheld/)
encountered discrete success on [hackernews](https://news.ycombinator.com/item?id=20830037), The Raspberry Pi 3B+ full keyboard handheld is finally ready! (A premise: it is **really** ugly).

Huge thanks to Anthony DiGirolamo for providing us with the **Open Sourced** [case and keyboard PCB](https://github.com/AnthonyDiGirolamo/teensy-thumb-keyboard) ❤️

# Completing the build


![assembling the build](/assets/images/buildingpi1.jpeg)

What was left to do in Part 1 was assembling all the components together inside the 3D-printed case. I've used M2.5 screws to secure all the parts together and I had to solder the wires connecting the keyboard and **Adafruit Powerboost** to the Pi. I also soldered a small power switch to the Powerboost.

Assembling the keyboard faceplate was tedious, a friend of mine 3D printed the components for me but the printer was not precise enough. Keycaps are kept in place by a small piece of plastic that fits through a hole in each single key, due to the printer not being precise enough hole and pins do not fit together perfectly, so some keys get stuck or are too lose. 

### Wiring connections

![wiring](/assets/images/wiring.jpg)

The wiring connection scheme is the following:

```
Rpi3B+   PowerBoost
PP2      5V
PP3      GND
```

```
Rpi3B+   Teensy 3.2/LC USB Surface Pads
PP48     GND
PP47     D+
PP46     D-
PP27     VUSB
```

I've restyled the original key labels by using the FreeMono font in Inkscape since the font used in the original design was not free. I had the labels printed on a PVC sticker sheet and then I manually cut and pasted the stickers on top of the 3D printed keys.
The result is uglier than Anthony's [original build](https://www.thingiverse.com/thing:3209958) (he got labels printed directly on the keycaps), but at least the keyboard is perfectly functional.

![key labels in inkscape](/assets/images/keylabelsinkscape.png)

### The really ugly but working prototype

![Text editor running on the Pi](/assets/images/editorpi.jpg)
![Completed build](/assets/images/completepi2.jpg)


# Portable freedom!

One of the many good things about this device is that you have an enormous choice of Operating Systems, UIs and software to run, if you want, you can also try to run 99% Free and Open Source software on this device. 
The only caveat (as covered in part 1) is getting the Hyperpixel 4 Display [driver](https://github.com/pimoroni/hyperpixel4)
to work, and to calibrate the touchscreen. 

My distro of choice is [Void Linux](https://voidlinux.org) because of its simplicity and its excellent package manager. 
You may also use NOOBS and Raspbian on the handheld with ease.
I'm using the i3wm window manager with a configuration almost identical to my desktop build,
since I'm using git over ssh to sync my dotfiles repository between devices and rsync to move files around my local network.

Anthony DiGirolamo's Teensy Thumb mechanical keyboard is really pleasing to use for chatting, typing and coding. There is an [endless](https://voidlinux.org/packages/) number of packages that you can install on a Raspberry Pi. To install bulkier applications you may even use **flatpak**! 

![Running Doom!](/assets/images/doompi.jpg)

I have been using the device for almost three weeks now and some keys already look really worn out (or stickers have fallen off). Using stickers for the keys was not really a good choice.

### What can I do with the handheld?

* Browse the web, read mail and watch videos using **Firefox** or **Chromium**.
* Hook up the Pi to an external **HDMI Screen** in seconds to watch a movie at a friends house.
* Write code with **nano**, **emacs**, **vim** or **kakoune**.
* Use **git** and **ssh** to do important work wherever you are.
* **Hack** around in the terminal or **run code** on the go with hundreds of supported programming languages.
* Play hundreds of **retro games** using emulators and **EmulationStation**.
* Use up to 3 USB devices such as a **gamepad**, **full keyboard and mouse**, **WiFi cards** and even your **Arduino**.
* Chat using **Telegram Desktop** or an **IRC Client**.
* Edit your papers using **TexStudio** (through flatpak).
* Do maths on the go using **graphing calculators** and **GNU Octave**.
* Manage your appointments and to-do list using [calcurse](https://calcurse.org/)
* Look like you came out of a 90s movie @ the hackerspace.


# Expectations

After I booted up the completed handheld for the first time I was amazed. 

The battery life is great with a 2300mAh battery (I've had to replace the 5Ah one because it did not fit inside the case), the build quality is fine, components are tightly packed together, the keyboard feels really clicky and typing on it is really pleasing, although it does not look good at all with sticker labels. 

I am happy to say that this project exceeded my satisfaction expectations.
If your kid is into computer science or electronics this may be a good you can build together.
If you want to build this you can get the V1 Teensy Thumb Board PCB on the [tindie product page](https://www.tindie.com/products/anthonysavatar/teensy-thumb-keyboard-pcb-only/). You may also order the PCB yourself from a manufacturer, detailed instructions are on the product page.

This device is inexpensive and easy to build, and with the [v2 keyboard](https://hackaday.io/project/162281-teensy-thumb-keyboard/log/164899-working-on-v2) in development (using SMD pre-soldered tactile switches and I2C bus) it may also become easier to assemble in the future. By doing some searches I have found a [similar handheld](https://twitter.com/hashtag/hyperkeyboardpi?src=hash) on twitter, built with a laser cut frame and faceplate. The kit was on sale for ~65 USD in Japan but the product page seems to be down. In the next version of the handheld I will try to design a different, laser cut case without keycaps to make the keyboard look and feel nicer and to make assembling the handheld easier and cheaper. 

### The Hyper Keyboard Pi, a similar handheld device from japan.

![Hyper keyboard Pi](/assets/images/hyperkeyboardpi.jpg)

# Follow up

In the next posts I'll:

* Talk about the development of the second version of the handheld.
* Add the official RPI camera, a speaker and a microphone
* Upgrade the build with an RPI 4.
* Upgrade to a bigger battery.
* Find a way to fit a 4G cellular modem module in the build.