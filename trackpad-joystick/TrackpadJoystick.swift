//
//  TrackpadJoystick.swift
//  trackpad-joystick
//
//  Created by ussserrr on 14/01/2019.
//  Copyright © 2019 ussserrr. All rights reserved.
//


import Cocoa



struct CenteredCoords {
    
    var x: Float32 = 0.0
    var y: Float32 = 0.0
    
    
    // Centered - default (x,y - coordinates with the origin point at the center of the trackpad [-1; 1])
    init(x: Float32, y: Float32) {
        assert(-1.0...1.0 ~= x && -1.0...1.0 ~= y, "both (x,y) should be in range [-1.0; 1.0], got \(x, y)")
        self.x = x
        self.y = y
    }
    
    // Normalized (x,y - coordinates with the origin point at the bottom left corner of the trackpad [0; 1])
    init(from normalized_x: CGFloat, from normalized_y: CGFloat) {
        assert(0.0...1.0 ~= normalized_x && 0.0...1.0 ~= normalized_y, "both (x,y) should be in range [0.0; 1.0], got \(normalized_x, normalized_y)")
        self.x = Float32((normalized_x-0.5)*2.0)
        self.y = Float32((normalized_y-0.5)*2.0)
    }

    // From NSTouch (extract coordinates from NSTouch)
    init(from touch: NSTouch) {
        self.init(from: touch.normalizedPosition.x, from: touch.normalizedPosition.y)
    }
    
    
    func toCentered() -> (x: Float32, y: Float32) {
        return (self.x, self.y)
    }
    
    func toNormalized() -> (x: CGFloat, y: CGFloat) {
        return (CGFloat((self.x/2.0)+0.5), CGFloat((self.y/2.0)+0.5))
    }
    
    func toScreenCoordinates() -> (x: CGFloat, y: CGFloat) {
        struct screen {
            static let width = NSScreen.main!.frame.width
            static let height = NSScreen.main!.frame.height
        }
        let (x, y) = toNormalized()
        return (CGFloat(x)*screen.width, CGFloat(y)*screen.height)
    }
}



class TrackpadJoystick: NSView {
    
    @IBOutlet weak var infoLabel: NSTextField!
    @IBOutlet weak var coordsLabel: NSTextField!

    let mainScreen = NSScreen.main!
    
    var touch = NSTouch()
    var currentTouch = NSTouch()
    
    var acceptNewTouch = true
    var coordinatesDidUpdate = true
    
    var touchCircle = NSBezierPath()
    let touchCircleColor = NSColor.blue
    
    let stickStartPositionRadius: Float = 0.2
    
    
    // Initialization
    override func awakeFromNib() {
        super.awakeFromNib()

        self.allowedTouchTypes = NSTouch.TouchTypeMask(type: .indirect)

        NSCursor.hide()  // hide the mouse cursor

        self.setFrameSize(NSSize(width: mainScreen.frame.width, height: mainScreen.frame.height))

        infoLabel.stringValue = "Welcome to Trackpad Joystick"
    }
    
    
    override func draw(_ dirtyRect: NSRect) {
        
        // Drawing code here.
        
        // enterFullScreenMode prohibits touches if gets called from awakeFromNib so we do it from here as a workaround
        if !self.isInFullScreenMode {
            self.enterFullScreenMode(mainScreen, withOptions: nil)
        }
        
        if coordinatesDidUpdate {
            coordsLabel.stringValue = "x = \(centeredCoords.x)\ny = \(centeredCoords.y)"

            let (x, y) = centeredCoords.toScreenCoordinates()
            touchCircle.removeAllPoints()
            touchCircle = NSBezierPath(ovalIn: NSRect(x: x-12.0, y: y-12.0, width: 24.0, height: 24.0))
            touchCircleColor.set()
            touchCircle.fill()
        }
        
    }
    
    
    override func touchesBegan(with event: NSEvent) {
        if acceptNewTouch {
            touch = Array(event.touches(matching: .began, in: self))[0]

            // Stick start zone - circle
            let (x, y) = CenteredCoords(from: touch).toCentered()
            if pow(x, 2) + pow(y, 2) > pow(stickStartPositionRadius, 2) {
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
        print("Touch is cancelled")  // TODO: [ ]   throw an exception, change to NSLog()
    }
    
    
    var centeredCoords: CenteredCoords {
        get {
            if !acceptNewTouch {
                return CenteredCoords(from: currentTouch)
            } else {
                return CenteredCoords(x: 0.0, y: 0.0)
            }
        }
    }
    
    
    // TODO list:
    
    // [ ]   do not rely on external UI elements - define them internally instead or remove entirely
    // [ ]   configuration: on/off logs, features (at build and/or execution time)
    // [ ]   animate using Core Animation
    // [x]   coordinates getter
    // [ ]   emit some kind of event
    // [x]   add methods for converting coordinates (for drawing and other tasks)
    // [ ]   add non-linear scales
    // [x]   add reset to zero position after releasing the stick
    // [x]   add start (zero) zone (set as radius around (0.0, 0.0))
    
}
