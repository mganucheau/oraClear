#oraClear



##Components

Each unit contains one of the following components:

* [USB Microphone](https://www.adafruit.com/product/3367)
* [Raspberry Pi 3 B+](https://www.adafruit.com/product/3775)
* [SD Card](https://www.adafruit.com/product/2820)
* [PiTFT 3.5" resistive touch screen](https://www.adafruit.com/product/2441)
* [USB Battery](https://www.amazon.com/Anker-PowerCore-Lipstick-Sized-Generation-Batteries/dp/B005X1Y7I2/)
	

##Installation Instructions

1. Install [Raspbian](https://www.raspberrypi.org/downloads/raspbian/) using [Etcher](https://etcher.io/)

	* Setup headless SSH by placing a file named “ssh” (without any extension) onto the boot partition of the SD card. ([Source Link](https://hackernoon.com/raspberry-pi-headless-install-462ccabd75d0))

2. Connect to the Pi

	Plug in your pi and connect it to the network via ethernet.

	From your own terminal:

	```
	sudo ssh pi@raspberrypi
	```


	```
	username: pi
	password: raspberry
	```

3. Configure and Update the Pi

	```
	sudo apt-get update
	sudo apt-get upgrade
	```

	```
	sudo raspi-config
	```
	* Configure your Wifi
	* Change password
	* Set boot to autologin to desktop
	
	Change the Pi's hostname
	
	```	
	sudo nano /etc/hostname
	```
	
	Rename 'hostname' to oraClearX (X = the unit number)
	

4. Setup VNC ([Source Link](http://4dc5.com/2012/06/12/setting-up-vnc-on-raspberry-pi-for-mac-access/))

	```
	sudo apt-get install netatalk
	```
	Now from the Mac, open Finder, and hit ⌘K. Enter afp://hostname to connect. (hostname = oraClearX) 
	
	```
	sudo apt-get install avahi-daemon
	sudo update-rc.d avahi-daemon defaults
	```
	
	Now create a file /etc/avahi/services/afpd.service (as root):
	
	```
	sudo nano /etc/avahi/services/afpd.service
	```
	
	and add this content:
	
	```
	<?xml version="1.0" standalone='no'?><!--*-nxml-*-->
	<!DOCTYPE service-group SYSTEM "avahi-service.dtd">
	<service-group>
	   <name replace-wildcards="yes">%h</name>
	   <service>
	      <type>_afpovertcp._tcp</type>
	      <port>548</port>
	   </service>
	</service-group>
	
	```
	
	Then run this command:
	
	```
	sudo /etc/init.d/avahi-daemon restart
	```
	

5. Setup a VNC Server ([Source Link](http://4dc5.com/2012/06/12/setting-up-vnc-on-raspberry-pi-for-mac-access/))
	
	```
	sudo apt-get install tightvncserver
	vncserver
	```
	
	Configure a boot script.
	
	```	
	cd /etc/init.d
	sudo nano tightvncserver
	```

	and add this content:
	
	```
	#!/bin/bash
	# /etc/init.d/tightvncserver
	#
	
	# Carry out specific functions when asked to by the system
	case "$1" in
	start)
	    su pi -c '/usr/bin/vncserver -geometry 1440x900'
	    echo "Starting VNC server "
	    ;;
	stop)
	    pkill vncserver
	    echo "VNC Server has been stopped (didn't double check though)"
	    ;;
	*)
	    echo "Usage: /etc/init.d/blah {start|stop}"
	    exit 1
	    ;;
	esac
	
	exit 0

	```
	Next
		
	```
	sudo chmod +x tightvncserver
	sudo pkill Xtightvnc	
	```

	```
	sudo /etc/init.d/tightvncserver start
	cd /etc/init.d
	sudo update-rc.d tightvncserver defaults
	```

6. Setup Bonjour for the VNC server. ([Source Link](http://4dc5.com/2012/06/12/setting-up-vnc-on-raspberry-pi-for-mac-access/))

	```
	sudo nano /etc/avahi/services/rfb.service
	```

	```
	<?xml version="1.0" standalone='no'?>
	<!DOCTYPE service-group SYSTEM "avahi-service.dtd">
	<service-group>
	  <name replace-wildcards="yes">%h</name>
	  <service>
	    <type>_rfb._tcp</type>
	    <port>5901</port>
	  </service>
	</service-group>
	```

	Restart the server
	
	```
	sudo /etc/init.d/avahi-daemon restart
	```

7. Install PiTFT Screen Drivers ([Source Link](https://learn.adafruit.com/adafruit-pitft-3-dot-5-touch-screen-for-raspberry-pi/easy-install-2))

	```
	cd ~
	wget https://raw.githubusercontent.com/adafruit/Raspberry-Pi-Installer-Scripts/master/adafruit-pitft.sh
	chmod +x adafruit-pitft.sh
	sudo ./adafruit-pitft.sh
	```
	
	Configuratino questions: 
	- Select PiTFT 3.5" resistive touch (320x480)
	- Set Rotation to 270 degrees (landscape)
	- Would you like the console to appear on the PiTFT display? No
	- Would you like the HDMI display to mirror the PiTFT display? Yes 
	

8. Disable Screen Blinking ([Source Link](https://learn.adafruit.com/processing-on-the-raspberry-pi-and-pitft/processing))

	```
	sudo nano /etc/lightdm/lightdm.conf
	```
	
	Then scroll down to the [SeatDefaults] line and change the #xserver-command=X line beneath it to look like:
	
	```
	xserver-command=X -s 0 -dpms
	```


9. Configure Screen Rotation, Speed, FPS - ([Source Link](https://learn.adafruit.com/adafruit-pitft-3-dot-5-touch-screen-for-raspberry-pi/faq))

	```
	sudo nano /boot/config.txt
	```
	
	```
	dtoverlay=pitft35-resistive,rotate=270,speed= 62000000,fps=60
 	```

 
10. Setup Processing ([Source Link](https://forum.processing.org/two/discussion/22968/start-processing-sketch-at-pi-startup))

	Install Processing
	
		
	```
	curl https://processing.org/download/install-arm.sh | sudo sh
	```


	Install Sound Library:
	
	```
	git clone git@github.com:processing/processing-sound.git

	```

	Set Processing to boot on start
	
	```
	sudo nano ~/.config/lxsession/LXDE-pi/autostart
	```

	```
	/usr/local/bin/processing-java --sketch=/home/pi/oraClear --run
	```
