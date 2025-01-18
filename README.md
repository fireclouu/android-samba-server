# android-samba-server
Script automation for Samba server running on Android via Termux app, and using Windows PC native samba server without needing external application

## Method
On Windows client, it uses port forwarding to localhost, by disabling `Lanmanserver` and redirect Android Samba server running on port 4445 and 1139.

## How to use
It is REQUIRED to connect your Android and Windows devices on the same network before doing steps below. For example, Android wi-fi hotspot, USB tethering, your router home network.

Please note also that performance will vary with the choice of your network setup.

### Android (Server)
Download [Termux app](https://github.com/termux/termux-app/releases) and paste this on terminal:
```
curl -O https://raw.githubusercontent.com/fireclouu/android-samba-server/main/server.sh && chmod +x server.sh && ./server.sh -o
```

> [!NOTE]
> Remove -o parameter if you plan to configure your smb.conf located at $PREFIX/etc folder

It will automate the process. On first usage, supply a `password` when asked, then next time using the script, you can leave it unchanged.

### Windows (Client)
Open Powershell, and paste this:
```
curl -O https://raw.githubusercontent.com/fireclouu/android-samba-server/main/client-windows.sh 
```
At first, script will tell you to reboot due to disabling of `Lanmanserver` to take effect.

The next time you run the script, it will ask for server IP. This is listed on interfaces provided on server, pick either wifi IP, RDNS ID, etc, that matches your network setup.

It will automate the connection and binding process and will ask for server password you just did on server-side.

## Issues
On server-side, I tested it on my own device running Android 14 and HyperOS and OneUI, both working flawlessly.

Client-side I use Windows 11 Home 23H2 build 22631.4602 and works fine.
