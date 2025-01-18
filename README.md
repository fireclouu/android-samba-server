# android-samba-server
Script automation for Samba server running on Android via Termux app, and using Windows PC native samba server without needing external application

## Method
On Windows client, it uses port forwarding to localhost, by disabling `Lanmanserver` and redirect Android Samba server running on port 4445 and 1139.

## How to use
It is REQUIRED to connect your Android and Windows devices on the same network before doing steps below. For example, Android wi-fi hotspot, USB tethering, your router home network.

Please note also that performance will vary with the choice of your network setup.

### Android
Download [Termux app](https://github.com/termux/termux-app/releases) and paste this on terminal:
```
curl -sSL https://raw.githubusercontent.com/fireclouu/android-samba-server/server.sh | bash
```

It will automate the process. On first usage, supply a `password` when asked, then next time using the script, you can leave it unchanged.

### Windows
Open Powershell, and paste this:
```
curl -sSL https://raw.githubusercontent.com/fireclouu/android-samba-server/main/client-windows.sh | bash
```
