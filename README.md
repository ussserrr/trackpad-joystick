# Trackpad Joystick

![demo](/demo.gif)

Example of how to use MacBook's or Apple Magic Trackpad not for a positioning of the cursor but for getting an absolute coordinates of touches - i.e. as a joystick.

The project ([`TrackpadJoystick.swift`](/trackpad-joystick/TrackpadJoystick.swift)) is combined with a simple example ([`ViewController.swift`](/trackpad-joystick/ViewController.swift)) - sending a coordinates over an UDP socket.


## Overview
The idea behind the application is to use a custom view - subclass of `NSView` - to receive one touch at a time. To emulate a real joystick behavior touches are allowed to begin only from the center of he trackpad - in a circle with `stickStartPositionRadius` radius. Also, after releasing a finger from the panel the stick is automatically returning to the start position.

Coordinates are retrieving in a real time on every request to the `TrackpadJoystick.centeredCoords` member.

To prevent distractions in cases when the window is losing focus the app is running itself in a fullscreen mode (use Cmd+Q to exit). Currently, I haven't found a simple way to make an `NSView` a fully transparent overlay in a fullscreen mode to place other UI elements behind it and not relate on them in the main `TrackpadJoystick` class. So if you want any additional UI components please put them in this class.


## Installation
TrackpadJoystick itself has no dependencies although the example has one - it uses [IBM-Swift/BlueSocket](https://github.com/IBM-Swift/BlueSocket) as a simple socket framework.
 - Install IBM-Swift/BlueSocket via Carthage (`carthage update`)
 - Turn on network connections (Project settings -> Capabilities -> App Sandbox -> Network)
 - Create and configure UI and outlets in Interface Builder


## Usage
