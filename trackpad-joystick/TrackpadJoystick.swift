//
//  TrackpadJoystick.swift
//  trackpad-joystick
//
//  Created by ussserrr on 14/01/2019.
//  Copyright © 2019 ussserrr. All rights reserved.
//


import Cocoa


class TrackpadJoystick: NSView {
    
    // TODO: do not rely on external UI elements - define them internally instead or remove entirely
    @IBOutlet weak var infoLabel: NSTextField!
    @IBOutlet weak var coordsLabel: NSTextField!

    let mainScreen = NSScreen.main!
    
    var touch = NSTouch()
    var currentTouch = NSTouch()
    
    var acceptNewTouch = true
    var coordinatesDidUpdate = false
    
    var touchCircle = NSBezierPath()
    let touchCircleColor = NSColor.blue
    
    
    override func awakeFromNib() {
        super.awakeFromNib()

        self.allowedTouchTypes = NSTouch.TouchTypeMask(type: .indirect)

        NSCursor.hide()  // hide the mouse cursor

        self.setFrameSize(NSSize(width: mainScreen.frame.width, height: mainScreen.frame.height))
//        self.enterFullScreenMode(mainScreen, withOptions: nil)

        infoLabel.stringValue = "Welcome to Trackpad Joystick"
    }
    
    
    override func draw(_ dirtyRect: NSRect) {
        
        // Drawing code here.
        
        // enterFullScreenMode prohibits touches if gets called from awakeFromNib so we do it from here
        if !self.isInFullScreenMode {
            self.enterFullScreenMode(mainScreen, withOptions: nil)
        }
        
        if coordinatesDidUpdate {
            coordsLabel.stringValue = "x = \(currentTouch.normalizedPosition.x)\ny = \(currentTouch.normalizedPosition.y)"
            
            touchCircle.removeAllPoints()
            touchCircle = NSBezierPath(ovalIn: NSRect(x: mainScreen.frame.width*currentTouch.normalizedPosition.x, y: mainScreen.frame.height*currentTouch.normalizedPosition.y, width: 25.0, height: 25.0))
            touchCircleColor.set()
            touchCircle.fill()
        }
        
    }
    
    
    override func touchesBegan(with event: NSEvent) {
        if acceptNewTouch {
            touch = Array(event.touches(matching: .began, in: self))[0]
            currentTouch = touch
            acceptNewTouch = false
            coordinatesDidUpdate = true
            self.needsDisplay = true
            coordsLabel.needsDisplay = true
        }
        else {
            coordinatesDidUpdate = false
        }
//        print("Touch \(touch.identity) began at \(touch.normalizedPosition)")
        coordsLabel.stringValue = "x = \(touch.normalizedPosition.x)\ny = \(touch.normalizedPosition.y)"
    }
    
    override func touchesMoved(with event: NSEvent) {
        currentTouch = Array(event.touches(matching: .moved, in: self))[0]
        if currentTouch.identity.isEqual(touch.identity) {
            coordinatesDidUpdate = true
            self.needsDisplay = true
        }
        else {
            coordinatesDidUpdate = false
        }
//        print("Touch \(currentTouch.identity) moved to \(currentTouch.normalizedPosition)")
        coordsLabel.stringValue = "x = \(touch.normalizedPosition.x)\ny = \(touch.normalizedPosition.y)"
    }
    
    override func touchesEnded(with event: NSEvent) {
        currentTouch = Array(event.touches(matching: .ended, in: self))[0]
        if currentTouch.identity.isEqual(touch.identity) {
            coordinatesDidUpdate = true
            acceptNewTouch = true
            self.needsDisplay = true
        }
        else {
            coordinatesDidUpdate = false
        }
//        print("Touch \(currentTouch.identity) ended at \(currentTouch.normalizedPosition)")
        coordsLabel.stringValue = "x = \(touch.normalizedPosition.x)\ny = \(touch.normalizedPosition.y)"
    }
    
    override func touchesCancelled(with event: NSEvent) {
        print("Touch is cancelled")  // TODO: throw an exception
    }
    
    
    // TODO:
    
    // log configuration
    
    // coords { get }
    // or
    // func coords_get()
    
    
}
