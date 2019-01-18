//
//  TrackpadJoystick.swift
//  trackpad-joystick
//
//  Created by ussserrr on 14/01/2019.
//  Copyright © 2019 ussserrr. All rights reserved.
//


import Cocoa


struct Coords {
    var x: CGFloat = 0.0
    var y: CGFloat = 0.0
}


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
            if let c = coords {
                coordsLabel.stringValue = "x = \(c.x)\ny = \(c.y)"
            }
            
            touchCircle.removeAllPoints()
            touchCircle = NSBezierPath(ovalIn: NSRect(x: mainScreen.frame.width*currentTouch.normalizedPosition.x-12.0, y: mainScreen.frame.height*currentTouch.normalizedPosition.y-12.0, width: 24.0, height: 24.0))
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
    }
    
    override func touchesCancelled(with event: NSEvent) {
        print("Touch is cancelled")  // TODO: throw an exception
    }
    
    
    var coords: Coords? {
        get {
            if !acceptNewTouch {
                return Coords(x: (currentTouch.normalizedPosition.x-0.5)*2.0, y: (currentTouch.normalizedPosition.y-0.5)*2.0)
            }
            else {
                return nil
            }
        }
    }
    
    
    // TODO:
    
    // log configuration
    
    // coords { get }
    // or
    // func coords_get()
    // emit some kind of event
    
    
}
