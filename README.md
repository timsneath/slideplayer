# Flutter Slides

Flutter Slides utilizes [Flutter Desktop Embedding](https://github.com/google/flutter-desktop-embedding) to provide a simple slide presentation app.  Presentations are data driven from files on the disk, so users can create their own presentations without needing to update any code in the project. 

The [wiki](https://github.com/flutter/slideplayer/wiki) contains documentation about the presentation file structure, content type information, exporting and sharing, and more.
  
![\_](https://i.imgur.com/n3o7OZM.png)

## Features
- Supports any properly formatted presentation.  See the [wiki](https://github.com/flutter/slideplayer/wiki) for details on the file format.
- Live updates when presentation file is updated and saved
- Advancement steps
- Reveal animations
- Custom Flutter content (requires code changes)

# Getting Started
  
**Currently only macOS is supported.**  

## Building 

### Requirements
- XCode 10 or higher
- Flutter 1.0 or later

### Setting Up

The tooling and build infrastructure for this project requires that you have
a Flutter tree and Flutter Desktop Embedding in the same parent directory as the clone 
of this project:

```
<parent dir>
  ├─ flutter (from http://github.com/flutter/flutter)
  ├─ flutter-desktop-embedding (from https://github.com/google/flutter-desktop-embedding)
  └─ flutter_slides (from https://github.com/flutter/slideplayer)
```

Alternately, you can place a `.flutter_location_config` file in the directory
containing flutter-desktop-embedding, containing a path to the Flutter tree to
use, if you prefer not to have the Flutter tree next to flutter-desktop-emebbing.

### Running
Open `FlutterSlides.xcodeproj` under macos, and build and run the `Flutter Slides` target.
If you happen to get a build error on your first run, try cleaning and running again.
  
Once it's running, you can open the file `flutter_live.json` in the `example_presentation` folder of the root of the project as a sample.

## Running the app
1. Go to File -> Open (or tap the Open button if it is visible)
2. Select a Flutter Slides file.  An example is supplied with `flutter_live.json`  in the `example_presentation` folder located in the root of the project.  The next time you run the app, it will automatically attempt to open this file.
3. Use the controls listed below to navigate through the app.

**To advance:**
- right arrow
- or, spacebar

**To go back:**
- left arrow

**To toggle slide selector sidebar:**
- `]` to show
- `[` to hide

**To change to a new slide in sidebar:**
- `z + click` on the slide
   
**To present fullscreen**
- `cmd + ctl + F`
- or, select the green "full screen" button in the upper left of the window
   
**To leave fullscreen**
- `cmd + ctl + F`
- or, move your cursor to the top of the screen and tap the green button in upper left

