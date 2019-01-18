# Trackpad Joystick

![demo](/demo.gif)

Example of how to use MacBook or Apple Magic Trackpad not for a positioning of the cursor but for getting an absolute coordinates of touches - i.e. as a joystick.

This Cocoa application uses a custom view - subclass of NSView - to receive one touch at a time.

To prevent distractions when losing window focus the app is running itself in a fullscreen mode (use Cmd+Q to exit).


## Installation
 - Turn on network connections (Project settings -> Capabilities -> App Sandbox -> Network)
 - Create and configure UI and outlets in Interface Builder
