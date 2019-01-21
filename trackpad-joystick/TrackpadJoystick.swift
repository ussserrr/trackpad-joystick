//
//  TrackpadJoystick.swift
//  trackpad-joystick
//
//  Created by ussserrr on 14/01/2019.
//  Copyright © 2019 ussserrr. All rights reserved.
//


import Cocoa


struct Coords {
    var x: Float32 = 0.0
    var y: Float32 = 0.0
}


class TrackpadJoystick: NSView {
    
    // TODO: do not rely on external UI elements - define them internally instead or remove entirely
    @IBOutlet weak var infoLabel: NSTextField!
    @IBOutlet weak var coordsLabel: NSTextField!

    let mainScreen = NSScreen.main!
    
    var touch = NSTouch()
    var currentTouch = NSTouch()
    
    var acceptNewTouch = true
    var coordinatesDidUpdate = true
    
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
        
        // enterFullScreenMode prohibits touches if gets called from awakeFromNib so we do it from here as a workaround
        if !self.isInFullScreenMode {
            self.enterFullScreenMode(mainScreen, withOptions: nil)
        }
        
        if coordinatesDidUpdate {
//            if let c = coords {
                coordsLabel.stringValue = "x = \(coords.x)\ny = \(coords.y)"
//            }
            
            touchCircle.removeAllPoints()
            touchCircle = NSBezierPath(ovalIn: NSRect(x: mainScreen.frame.width*CGFloat((coords.x/2.0)+0.5)-12.0, y: mainScreen.frame.height*CGFloat((coords.y/2.0)+0.5)-12.0, width: 24.0, height: 24.0))
            touchCircleColor.set()
            touchCircle.fill()
        }
        
    }
    
    
    override func touchesBegan(with event: NSEvent) {
        if acceptNewTouch {
            touch = Array(event.touches(matching: .began, in: self))[0]
            // rectangle, maybe change to circle
            if ((touch.normalizedPosition.x-0.5)*2.0 < -0.2) || ((touch.normalizedPosition.x-0.5)*2.0 > 0.2) || ((touch.normalizedPosition.y-0.5)*2.0 < -0.2) || ((touch.normalizedPosition.y-0.5)*2.0 > 0.2) {
                touch = NSTouch()  // reset an identity
                return
            }
            currentTouch = touch
            acceptNewTouch = false
            coordinatesDidUpdate = true
            self.needsDisplay = true
            coordsLabel.needsDisplay = true
        } else {
            coordinatesDidUpdate = false
        }
//        print("Touch \(touch.identity) began at \(touch.normalizedPosition)")
    }
    
    override func touchesMoved(with event: NSEvent) {
        currentTouch = Array(event.touches(matching: .moved, in: self))[0]
        if currentTouch.identity.isEqual(touch.identity) {
            coordinatesDidUpdate = true
            self.needsDisplay = true
        } else {
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
        } else {
            coordinatesDidUpdate = false
        }
//        print("Touch \(currentTouch.identity) ended at \(currentTouch.normalizedPosition)")
    }
    
    override func touchesCancelled(with event: NSEvent) {
        print("Touch is cancelled")  // TODO: throw an exception, change to NSLog()
    }
    
    
    var coords: Coords {
        // TODO: [ ]   add methods for converting coordinates (for drawing and other tasks)
        get {
            if !acceptNewTouch {
                return Coords(x: Float32((currentTouch.normalizedPosition.x-0.5)*2.0), y: Float32((currentTouch.normalizedPosition.y-0.5)*2.0))
            } else {
                return Coords(x: 0.0, y: 0.0)
            }
        }
    }
    
    
    // TODO list:
    
    // [ ]   configuration: on/off logs, features (at build or execution time)
    
    // [x]   coordinates getter
    // [ ]   emit some kind of event
    
    // [ ]   add non-linear scales
    // [x]   add reset to zero position after releasing the stick
    // [ ]   add start (zero) zone (set as radius around (0.0, 0.0))
    
}
