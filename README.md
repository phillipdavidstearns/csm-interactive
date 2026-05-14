# CSM Interactive

## Quick Links

1. [Operating Instructions](#operation)
1. [Troubleshooting](#troubleshooting)

## Overview

### Components

The installation consists of the following main components:

1. Projector
1. Instruments
	* Bodhran Frame Drum
	* Hang / Hand Pan
	* Kalimba + Mbira Array
1. Cabinet
	* Mac Mini
	* Focusrite Audio Interface
	* Philips TV/Monitor
	* Keyboard + Mouse

### Connections

* The **Mac Mini** connects to **Input 1**of the **Projector** by an HDMI cable.
* The **Bodhran** is connected to **Input 1** of the **Focusrite** using a custom contact mic, soldered to the end of a cable that terminates in and unbalanced 1/4" phone plug.
* The **Hand Pan** is picked up by a Samson S72 percussion microphone connected to **Input 2** of the **Focusrite**.
* The **Kalimba** is connected to **Input 3** of the *Focusrite* with an unbalanced 1/4" instrument cable.
* The **Focusrite** is connected to the **Mac Mini** by a USB C to USB A cable.

NOTE: The projector is the Mac Mini's main display. The Philips TV in the cabinet is there in the event that on-site troubleshooting is required. A wireless keyboard and mouse are paired with the Mac Mini.

### Software

The installation is powered by an application exported from Processing. Source code is linked [here](https://github.com/phillipdavidstearns/csm-interactive). The application leverages the processing.sound library to perform audio analysis.

Translation of sound into visuals is not direct; you will not see any waveforms or spectrograms. Instead, amplitude and transient information is used to "evolve" a generative system of cloud-like textures, vertical distortion, pixelsorting and feedback effects.

#### A basic outline of the algorithm:

1. The color palette information is set
1. In the main `draw()` function, first the audio is analyzed.
1. The background of an off-screen graphics buffer is set.
1. The output from the previous frame is processed by a feedback shader and drawn to the off-screen buffer.
1. "Noise clouds" are then rendered by the noise shader based on values set for each instrument after their initial analysis.
1. The off-screen buffer is finally drawn to the on-screen buffer.
1. Pixelsorting effect is applied (glitchy gradients)
1. Pixelshifting effect is applied (vertical distortion)
1. Forces are applied to the mass-spring system, which influences:
	* Pixelsorting effect
	* Feedback effect
1. Color palette information for next frame is updated.

Every 256 beat detection events, a transition between color palettes is initiated, during the middle of which, the pixelsorting algorithm is updated. Every 64, beat detection events, the pixel sorting algorithm is updated.

## Operation

* TURN ON at the beginning of the day by powering ON the projector using its remote. The projection should show the artwork.
	* If a **mouse cursor** is visible, use the wireless keyboard to press `command + tab` to select the "Interactive" application.
	* If the projector fails to find signal, the Mac Mini will need to be checked for power. Please refer to the [troubleshooting](#troubleshooting) section below
* TURN OFF at the end of the day by powering OFF the projector using its remote.

NOTE: Power to the installation should not be interrupted.

## Troubleshooting

### Cursor Visible?

There's a keyboard kept with the projector remote with the following instructions written on a post-it note taped to the back:

1. Turn on the keyboard.
1. Press spacebar until it is connected (indicated on screen).
1. Press and hold `command` + press `tab` until "Interactive" is selected.
1. Cursor should be gone!
1. Turn off the keyboard.

### Blank Screen?

After turning on the projector, if the projected image is blank/black or the projector can't seem to find signal on HDMI 1 **hint**. Here are some things for you to keep in mind and check in the meantime:

1. A blank screen indicates that the projector is getting signal. Something might be wrong with the Application. You may need to get a hold of me, Phil.
1. No Signal indicates that the projector is just not getting anything:
	1. Maybe the Mac Mini is off?
	1. If it's on, maybe the cable got disconnected?
		1. Check the back of the Mac Mini? (see on-site access)
		1. Check the projector?

* The Mac Mini has been configured to power up automagically if it loses power.
* Failing that, it should also automagically power-up at 9:30 AM. If it's not connected to power at that time, it won't happen.
* It's also configured to automagically login and launch the "Interactive" application, which runs in fullscreen mode.
* The only display device connected to the Mac Mini is the projector, Theoretically, if the boot sequence logged in and auto launched, the projector will not be blank or in want of a signal.

For all of the above, you can check my work below. I left notes indicating what I did to make the Mac Mini do the things it ought to do.

### Remote Access

Phil has the ability to access the Mac Mini in one of two ways:

* via `ssh` for remote commandline access
* via Apple Remote Management for screen sharing and control; think remote desktop.

If for whatever reason, the Mac Mini isn't connected to the Internet, some deeper digging is required on-site.

### Direct On-Site Access

* The access panel has four *quater-turn* latches.
	* **TO OPEN**, use a flathead driver to turn all four 90 degrees **CLOCKWISE**.
	* Using the top two latch insets, gently lift and pull access panel clear.
	* **TO CLOSE**, position the access panel and use a flathead driver to turn each latch 90 degrees **COUNTER-CLOCKWISE**

First thing to check is that everything is powered on:

* Power strip power switch is lit orange
* A tiny white light on the Mac Mini should be on
* The Focusrite has lights on
	* Red lights indicate "instrument" mode for inputs one and two
	* A green usb icon light indicates that it is connected to the Mac Mini OK.

If all these are present and the projector doesn't find signal, something more serious is afoot...

## Machine Setup

1. `sudo pmset repeat poweron MTWRFSU 00:09:30` to power on daily at 9:30am. [pmset manual](https://ss64.com/mac/pmset.html)
1. `sudo pmset -a autorestart 1` to enable automatic restart on power loss.
1. `sudo pmset -a sleep 0` to disable sleeping
1. Disable FileVault: System Settings > Privacy & Security > FileVault
1. Enable Automatically log in: System Settings > Users & Groups
1. Change settings for Lock Screen: System Settings > Lock Screen
	1. Start Screen Saver: Never
	1. Turn display off: Never
	1. Require password: Never
1. Check System Settings > Login Password "Automatically log in after reboot"

## VPN Access

1. Download and install wireguard from App store.
1. Configure to connect to remote VPN server.

## Remote Login via `ssh`

### On remote

1. System Settings > General > Sharing
1. Toggle on Remote Login
1. Click info button and check "Allow full disk access..."

### On local

#### Setup public key authentication 

1. copy your public key over to the machine `ssh-copy-id <user>@<vpn_ip_address>`
1. enter password
1. test access `ssh <user>@<vpn_ip_address>`

#### Harden sshd:

1. Add to bottom of `/etc/ssh/sshd_config`:

```
PermitRootLogin no
PubkeyAuthentication yes
PasswordAuthentication no
```

## Remote Management

### VNC Server (remote)

1. System Settings > General > Sharing
1. Click the info button for Remote Management
1. Add users and set privileges.
1. Toggle on Remote Management

### VNC Client (local)

1. From Finder, press `command + k`
1. Enter `vnc://<server_vpn_ip_address>`
1. Click connect
1. Enter credentials

## Application Setup

1. Application export without Java SDK files.
1. Download and install ["Eclipse Temurin" OpenJDK from Adoptium](https://adoptium.net/). JDK 25 LTS for MACOS x64 Architecture seemed to work (even though running on an M1 Mac Mini).
1. Move application to the Applications folder
1. Add it to Login items:
	1. System Settings > General > Login Items
	1. Click `+` and select from Applications folder. Note: If this doens't work, look into plist configuration.