# qr-code-reader
Ionic capacitor plugin serving as a qr code reader

# How to Use the Plugin in an Ionic Project

Create Blank Project
*  start qrCodeProject blank --type=angular --capacitor

Switch to project folder
* cd ./qrCodeProject

Install qr-code-reader plugin
* npm i ../qr-code-reader
 
Build app and add native platforms
* ionic build
* npx cap add ios
* npx cap add android

### Android Integration
Add Camera permission in android/app/src/main/AndroidManifest.xml file
* < uses-permission android:name="android.permission.CAMERA" />

Copy below code in android/app/src/main/java/io/ionic/starter/MainActivity.java file inside onCreate method
* add(QRCodePlugin.class);


### iOS Integration
* No changes required
