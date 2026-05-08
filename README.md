# CSM Interactive 

## Machine Setup

1. `sudo pmset repeat poweron MTWRFSU 00:06:00` to power on daily at 6am. [pmset manual](https://ss64.com/mac/pmset.html)
1. `sudo pmset -a autorestart 1` to enable automatic restart on power loss.
1. `sudo pmset -a sleep 0` to disable sleeping
1. Disable FileVault at System Settings > Privacy & Security > FileVault
1. Enable Automatically log in as at System Settings > Users & Groups
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

## Operating Instructions

1. With everything connected:
	1. Focusrite > MacMini

1. Test conditions:
	1. Startup with both connected and both powered off
	1. Startup with both connected and projector powered on
	1. Startup with both connected and monitor powered on
	1. Startup with both connected and both powered on
1. Test auto login for a user account and auto launch application
	1. See about configuring this from the admin account 