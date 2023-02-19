# Together Champions
_Together we create champions_

The Together Chpamions is a opensource project for **Gps Tracking Performance** to **track** and **analyze** your performance during sport. This sistem is a complete interation of **hardware and software** to enable you to create your own traking system from a starting point. You can download the app for all Destop system and from app store and play store for mobile.

# Hardware
Create your own hardare startiung from this.

# Software

## Download
### New release v. 0.0.2 [DOWNLOAD](https://github.com/kekko7072/lms/releases/tag/0.0.2)
This has new improvements and it's finally available on the [release note](https://github.com/kekko7072/lms/releases/tag/0.0.2) page.

## Release
Follow specific platform release pipeline and then create a release in GitHub where put the files.
### macOS
Archive the app in Xcode, Windows >Distribute App > Developer ID > Export Notarized App
### Windows
Run 'flutter build windows'. In the folder 'build/windows/runner/Release/', as said in [package instructions](https://pub.dev/packages/sqflite_common_ffi#windows) add the file sqlite3.dll [downlaod](https://github.com/tekartik/sqflite/raw/master/sqflite_common_ffi/lib/src/windows/sqlite3.dll) if it's not already there. Open the file desktop_inno_script.iss with Inno Setup Compiler and Run the script.

## Build
### macOS
Run on Debug or Release Mode.

### Windows
Follow this [video](https://www.youtube.com/watch?v=XvwX-hmYv0E) to build the .exe file. As said in [package instructions](https://pub.dev/packages/sqflite_common_ffi#windows) remember that in <b>release mode</b> you need to add the file sqlite3.dll [downlaod](https://github.com/tekartik/sqflite/raw/master/sqflite_common_ffi/lib/src/windows/sqlite3.dll) in same folder as your executable. Publish the LMS.exe file.

### Linux
Never tested.
