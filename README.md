# BleOta
Graphical application for upload firmware over Bluetooth.\
<img src="./assets/images/icon_color.svg" width="100">\
Fully works on `Android` and `iOS`. For other OS it depends on `flutter_reactive_ble` library.\
Local files upload is disabled by default to prevent unknown firmware upload by end users, enable it by changing `Always allow local files upload` in `Settings`.\
Additionally update functionality for specific hardwares is supported.
If you want end users have ability to update your hardware check `doc/ADD_NEW_HARDWARE.md`.

[<img src="https://upload.wikimedia.org/wikipedia/commons/7/78/Google_Play_Store_badge_EN.svg" 
alt="Download from Google Play" 
height="50">](https://play.google.com/store/apps/details?id=com.vovagorodok.ble_ota_app)&nbsp;&nbsp;&nbsp;
[<img src="https://upload.wikimedia.org/wikipedia/commons/a/a3/Get_it_on_F-Droid_%28material_design%29.svg" 
alt="Download from F-Droid" 
height="50">](https://f-droid.org/packages/com.vovagorodok.ble_ota_app/)&nbsp;&nbsp;&nbsp;
[<img src="https://upload.wikimedia.org/wikipedia/commons/3/3c/Download_on_the_App_Store_Badge.svg" 
alt="Download from App Store" 
height="50">](https://itunes.apple.com/us/app/ble_ota_app/id0000000000)

> **REMARK**: Application not released on `App Store` yet.
> Apple corporation require `100$/year` developer fees even for free and open source applications.
> If you want to support project, fill free to send me small amout or help with idea how to release app in `iOS` without developer fees.

## Peripheral device side
Arduino library: https://github.com/vovagorodok/ArduinoBleOTA
