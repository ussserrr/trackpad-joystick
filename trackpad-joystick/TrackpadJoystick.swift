//
//  TrackpadJoystick.swift
//  trackpad-joystick
//
//  Created by Андрей Чуфырев on 14/01/2019.
//  Copyright © 2019 ussserrr. All rights reserved.
//

import Cocoa

class TrackpadJoystick: NSView {
    
    // TODO: do not rely on external UI elements - define them internally instead
    @IBOutlet weak var infoLabel: NSTextField!
    @IBOutlet weak var coordsLabel: NSTextField!

    var isInit = false
    
    let mainScreen = NSScreen.main!
    
    var touch = NSTouch()
    var currentTouch = NSTouch()
    var acceptNewTouches = true
    var coordinatesHadUpdated = false
    
    var touchCircle = NSBezierPath()
    let touchCircleColor = NSColor.blue
    
    
    override func draw(_ dirtyRect: NSRect) {
        
        // Drawing code here.
        
        if !isInit {
            self.allowedTouchTypes = NSTouch.TouchTypeMask(type: NSTouch.TouchType.indirect)
//            self.acceptsTouchEvents = true  // deprecated

            self.setFrameSize(NSSize(width: mainScreen.frame.width, height: mainScreen.frame.height))
            self.enterFullScreenMode(mainScreen, withOptions: nil)
            
            infoLabel.setFrameSize(NSSize(width: mainScreen.frame.width, height: mainScreen.frame.height/2))
            infoLabel.setFrameOrigin(NSPoint(x: 0, y: mainScreen.frame.height/2))
            infoLabel.stringValue = "Welcome to Trackpad Joystick"
            
            coordsLabel.setFrameSize(NSSize(width: mainScreen.frame.width, height: mainScreen.frame.height/2))
            coordsLabel.setFrameOrigin(NSZeroPoint)
            
            isInit = true
        }
        
        if coordinatesHadUpdated {
            coordsLabel.stringValue = "x = \(currentTouch.normalizedPosition.x)\ny = \(currentTouch.normalizedPosition.y)"
            
            touchCircle.removeAllPoints()
            touchCircle = NSBezierPath(ovalIn: NSRect(x: mainScreen.frame.width*currentTouch.normalizedPosition.x, y: mainScreen.frame.height*currentTouch.normalizedPosition.y, width: 25.0, height: 25.0))
            touchCircleColor.set()
            touchCircle.fill()
        }
        
    }
    
    override func touchesBegan(with event: NSEvent) {
        if acceptNewTouches {
            touch = Array(event.touches(matching: .began, in: self))[0]
            currentTouch = touch
            acceptNewTouches = false
            coordinatesHadUpdated = true
            self.needsDisplay = true
            coordsLabel.needsDisplay = true
        }
        else {
            coordinatesHadUpdated = false
        }
//        print("Touch \(touch.identity) began at \(touch.normalizedPosition)")
        coordsLabel.stringValue = "x = \(touch.normalizedPosition.x)\ny = \(touch.normalizedPosition.y)"
    }
    
    override func touchesMoved(with event: NSEvent) {
        currentTouch = Array(event.touches(matching: .moved, in: self))[0]
        if currentTouch.identity.isEqual(touch.identity) {
            coordinatesHadUpdated = true
            self.needsDisplay = true
        }
        else {
            coordinatesHadUpdated = false
        }
//        print("Touch \(currentTouch.identity) moved to \(currentTouch.normalizedPosition)")
        coordsLabel.stringValue = "x = \(touch.normalizedPosition.x)\ny = \(touch.normalizedPosition.y)"
    }
    
    override func touchesEnded(with event: NSEvent) {
        currentTouch = Array(event.touches(matching: .ended, in: self))[0]
        if currentTouch.identity.isEqual(touch.identity) {
            coordinatesHadUpdated = true
            acceptNewTouches = true
            self.needsDisplay = true
        }
        else {
            coordinatesHadUpdated = false
        }
//        print("Touch \(currentTouch.identity) ended at \(currentTouch.normalizedPosition)")
        coordsLabel.stringValue = "x = \(touch.normalizedPosition.x)\ny = \(touch.normalizedPosition.y)"
    }
    
    override func touchesCancelled(with event: NSEvent) {
        print("Touch cancelled")  // TODO: throw an exception
    }

}
