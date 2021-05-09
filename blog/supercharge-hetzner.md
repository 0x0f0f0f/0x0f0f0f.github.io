@def title = "Supercharge your Cloud 1 - Installing Void Linux on Hetzner VPSs"
@def rss =  "Supercharge your Cloud 1 - Installing Void Linux on Hetzner VPSs"
@def published = "13 November 2020"
@def tags = ["void", "linux", "sysadmin", "hetzner", "cloud"]

{{post_header}}

Systemd sucks [^sd1], [^sd2], [^sd3], [^sd4], [^sd5] but [Hetzner Cloud](https://cloud.hetzner.com) rocks, and is one of my favourite VPS providers.
Hetzner has been providing Debian, Arch Linux, Ubuntu and CentOS images for cloud VPS instances, but wait!
They all use systemd! I have been using Void Linux for years now on mostly all of my devices. I have even
built a PDA that runs Void Linux [^voidpda].


Those days,  I was building a personal cloud instance with a few servers (more details in the following write-up posts),
and I ran into some very annoying issues that were directly caused by the unnecessary complexity of systemd. Docker was definitely resource overkill for this task. 

Let's jump straight to the guide on how to install Void Linux on a Hetzner Cloud VPS instance.

## Rescue Mode

The first step is to create a server on your Hetzner Cloud account. Choose Ubuntu as the initial OS image choice.
Do not add any volume or SSH key in the initial configuration wizard, as those will have to be manually managed after installing Void.
Do not upload anything on the server. The root partition will be formatted and wiped out!

After installing, turn off the server and boot in rescue mode.

![/posts/images/hetzner1.png](/assets/images/hetzner1.png)

You will be provided with an username (`root`) and a password for the rescue system. Copy this password somewhere!

Now is time to login into the rescue system by SSH-ing into the server, as you would normally do with the IPv4 address that Hetzner shows at the top of the server page:
```sh
ssh root@your-server-ipv4-address
```

## Unpacking the tarball

Login with the password Hetzner has just provided you, and run the `installimage` script. The following menu will be shown, choose
custom_image.

![/posts/images/hetzner2.png](/assets/images/hetzner2.png)

`installimage` will then open an editor with a configuration file.
Scroll down to the line containing `HOSTNAME` and change the value to the machine hostname you are going to set later.

Time to choose what image to install on the server! We will need a ROOTFS tarball of the system. I have not tested the `musl` version
and therefore I cannot recommend to use it. The standard `glibc` version works very fine for me.

Go on the Void Linux downloads repository [^voidrepo], scroll down at the very end and **copy the link**
of the x86_64 ROOTFS tarball. The file name will be something like this¸ 
but the build date will obviously become different in the future.

```
void-x86_64-ROOTFS-20191109.tar.xz
```

Be sure that the URL you have been copied looks like this:

```
https://alpha.de.repo.voidlinux.org/live/current/void-x86_64-ROOTFS-20191109.tar.xz
```

Now, go back to your rescue system SSH session, where we left it at the `installimage` config editor,
scroll down at the end of the config file, at the line starting with `IMAGE`, and paste
the Void Linux ROOTFS tarball URL after the word `IMAGE`, on the same line, like this:
```
IMAGE https://alpha.de.repo.voidlinux.org/live/current/void-x86_64-ROOTFS-20191109.tar.xz
```

You could change other settings in the config file, such as the disks partitioning, 
but for simplicity I have been sticking with the default, single root ext4 partition. 

Press F2 to save and then press F10 to exit. Hetzner's `installimage` script will format 
the `/dev/sda` and unpack the Void tarball automatically. It will probably fail at the end, but
don't worry! 

## Chroot time!

Now, the installer will probably exit with an error.
We should be fine if it has unpacked the tarball correctly in the `/dev/sda1` partition.
Now check if there is an ext4 partition in there, run:
```sh
lsblk -f
```

Now, mount it to `/mnt`.

```sh
mount /dev/sda1 /mnt
```

Check if `/mnt/` contains the Void ROOTFS tarball contents.
```sh
ls -lah /mnt
```

The rest of the guide is pretty much the guide for installing Void from chroot [^chroot], but is not identical!
Some steps are different (or not needed).
Though, I will still report the rest of the steps you need for setting up your Void VPS on Hetzner. 

Mount the pseudo-filesystems needed for a chroot:

```sh
for i in sys dev proc; do mount --rbind /$i /mnt/$i && mount --make-rslave /mnt/$i; done
```

Copy the DNS configuration into the new root so that XBPS can still download new packages inside the chroot:

```sh
cp /etc/resolv.conf /mnt/etc/
```

Chroot into the new installation:

```sh
PS1='(chroot) # ' chroot /mnt/ /bin/bash
```

Congrats! You're in the chroot.

## Finishing the installation

Check the internet connection:
```sh
ping voidlinux.org
```

ROOTFS images generally contain out of date software, due to being a snapshot of the time when they were built, and do not come with a complete `base-system`. Update the package manager and install `base-system`:

```sh
xbps-install -Su xbps
xbps-install -u
xbps-install base-system
xbps-remove base-voidstrap
```

Specify the hostname in `/etc/hostname`. Use the same one you used in the previous step when editing Hetzner `installimage`'s config:
```sh
echo 'yourhostname' > /etc/hostname
```

For glibc builds, generate locale files with:

```sh
xbps-reconfigure -f glibc-locales
```

Install your favourite text editor. I'm ok with nano.
```sh
xbps-install -S nano
```

Now edit `/etc/fstab`. This is very simple `fstab` is OK. See the references [^fstab] for more.
```
proc /proc proc defaults 0 0
/dev/sda1 / ext4 defaults,discard 0 0
```

Install GRUB. Hetzner uses DOS disk partitioning.
```
xbps-install grub
grub-install /dev/sda
```

Use xbps-reconfigure(1) to ensure all installed packages are configured properly:

```sh
xbps-reconfigure -fa
```

Congrats! You have now installed Void on Hetzner Cloud. 
You will need a couple of config tweaks before rebooting into a working install.
Don't exit from the `chroot` shell yet!

## Final tweaks
While still in the chroot, enable the `dhcpcd` service:
```sh
ln -s /etc/sv/dhcpcd /var/service/
```

Enable the `sshd` service for remote login through SSH.
I suggest you also install `ssh-audit`, and check out 
the awesome SSH HARDENING GUIDES [^sshhard] to ensure that
your Void VPS is safe and sound from unwanted remote logins.

```sh
ln -s /etc/sv/sshd /var/service/
```

Copy your SSH public key to your local PC clipboard and save it in the VPS root account `authorized_keys` file,
to later authorize your remote SSH login sessions.
```sh
mkdir /root/.ssh
nano /root/.ssh/authorized_keys
# paste your PUBLIC key in there and save
```

Change the root password
```sh
passwd root
```

Add an additional user
```sh
useradd --shell /bin/bash voiduser
```

Change its password
```sh
passwd voiduser
```

That's all! Have fun with your Void Linux VPS!

Now run `reboot` and login with SSH, as usual, into your fresh new Void Linux VPS!

## Additional Goodies


Uncomplicated Firewall. Don't enable before allowing the SSH port (change it from 22 to the port you are 
using if you changed it in your `sshd_config`) [^ufw]
```sh
xbps-install -S ufw
ln -s /etc/sv/ufw /var/service/ufw
ufw allow 22 # CHANGE THE PORT TO YOUR SSHD PORT IF IT IS NOT 22!
# add all the rules you like :)
ufw enable
```


dtach and dvtm [^dtach]
```sh
xbps-install -S dtach
dtach -A ~/dvtm-session -r winch dvtm
```
---

[^dtach]: https://www.digitalocean.com/community/tutorials/how-to-use-dvtm-and-dtach-as-a-terminal-window-manager-on-an-ubuntu-vps
[^ufw]: https://launchpad.net/ufw
[^sshhard]: https://www.sshaudit.com/hardening_guides.html
[^fstab]: https://docs.voidlinux.org/installation/guides/chroot.html#configure-fstab
[^chroot]: https://docs.voidlinux.org/installation/guides/chroot.html#entering-the-chroot
[^voidrepo]: https://alpha.de.repo.voidlinux.org/live/current/
[^sd1]: https://suckless.org/sucks/systemd/
[^sd2]: https://nosystemd.org/
[^sd3]: #systemdsucks on freenode!
[^sd4]: http://galexander.org/systemd_sucks.html
[^sd5]: https://news.ycombinator.com/item?id=12589281
[^voidpda]: Building a Raspberry Pi 3B+ full keyboard handheld. [Part 1](/posts/2019/08/building-a-raspberry-pi-3b-full-keyboard-handheld.-part-1/) [Part 2](/posts/2019/09/building-a-raspberry-pi-3b-full-keyboard-handheld.-part-2/)