//
//  TrackpadJoystick.swift
//  trackpad-joystick
//
//  Created by ussserrr on 14/01/2019.
//  Copyright © 2019 ussserrr. All rights reserved.
//


import Cocoa
import os



/// Struct to store joystick coordinates centered relatively to the trackpad center so the range of values is `[-1.0; 1.0]`.
///
/// Set getter in your `TrackpadJoystick` class to always have actual values on request.
struct CenteredCoords {
    
    var x: Float32 = 0.0
    var y: Float32 = 0.0
    
    
    /**
     Default initializer that simply copying already centered coordinates (with the origin point at the center of the trackpad).
     - Parameter x: Value of `x`. Must be in range `[-1.0; 1.0]`.
     - Parameter y: Value of `y`. Must be in range `[-1.0; 1.0]`.
     */
    init(x: Float32, y: Float32) {
        assert(-1.0...1.0 ~= x && -1.0...1.0 ~= y, "both (x,y) should be in range [-1.0; 1.0], got \(x, y)")
        self.x = x
        self.y = y
    }
    
    /**
     Initialize the structure converting normalized coordinates - that is, those ones with the origin point at the bottom left corner of the trackpad.
     - Parameter x: Normalized `x`. Must be in range `[0.0; 1.0]`.
     - Parameter y: Normalized `y`. Must be in range `[0.0; 1.0]`.
     */
    init(from normalized_x: CGFloat, from normalized_y: CGFloat) {
        assert(0.0...1.0 ~= normalized_x && 0.0...1.0 ~= normalized_y, "both (x,y) should be in range [0.0; 1.0], got \(normalized_x, normalized_y)")
        self.x = Float32((normalized_x-0.5)*2.0)
        self.y = Float32((normalized_y-0.5)*2.0)
    }

    /**
     Initialize the structure extracting coordinates from `NSTouch` instance.
     - Parameter touch: `NSTouch` instance.
     */
    init(from touch: NSTouch) {
        self.init(from: touch.normalizedPosition.x, from: touch.normalizedPosition.y)
    }
    
    
    /**
     Convert to coordinates with the origin point at the bottom left corner of the trackpad.
     - Returns: Tuple of coordinates, each one in the range `[0.0; 1.0]`.
     */
    func toNormalized() -> (x: CGFloat, y: CGFloat) {
        return (CGFloat((self.x/2.0)+0.5), CGFloat((self.y/2.0)+0.5))
    }
    
    /**
     Convert to screen `(width x height)` coordinates with the origin point at the bottom left corner of the trackpad.
     - Returns: Tuple of coordinates.
     */
    func toScreenCoords() -> (x: CGFloat, y: CGFloat) {
        // Use struct as a workaround to have local static constants
        struct screen {
            static let width = NSScreen.main!.frame.width
            static let height = NSScreen.main!.frame.height
        }
        let (x, y) = toNormalized()
        return (CGFloat(x)*screen.width, CGFloat(y)*screen.height)
    }
}



/// States of the TrackpadJoystick.
enum State {
    /// No any touch at the moment (coordinates are `(0.0; 0.0)`).
    case atOriginPoint
    /// `TrackpadJoystick` instance is currently handling the touch.
    case handlingTouch
    /// Some error has led to the current touch' abruption.
    case touchWasCancelled
}


/// Class providing trackpad joystick functionality.
class TrackpadJoystick: NSView {
    
    @IBOutlet weak var infoLabel: NSTextField!
    @IBOutlet weak var coordsLabel: NSTextField!

    let mainScreen = NSScreen.main!
    
    var touch = NSTouch()
    var currentTouch = NSTouch()
    
    var coordinatesDidUpdate = true
    
    var state = State.atOriginPoint
    
    var touchCircle = NSBezierPath()
    let touchCircleDiameter: CGFloat = 24.0
    let touchCircleColor = NSColor.blue
    
    let stickStartPositionRadius: Float = 0.2
    
    
    // Initialization
    override func awakeFromNib() {
        super.awakeFromNib()

        self.allowedTouchTypes = NSTouch.TouchTypeMask(type: .indirect)
        NSCursor.hide()  // hide the mouse cursor
        self.setFrameSize(NSSize(width: mainScreen.frame.width, height: mainScreen.frame.height))

        infoLabel.stringValue = """
        Welcome to Trackpad Joystick
        Press 'Q' to exit
        """
    }
    
    
    override func draw(_ dirtyRect: NSRect) {
        
        // Drawing code here.
        
        // enterFullScreenMode prohibits touches if gets called from awakeFromNib so we do it from here as a workaround
        if !self.isInFullScreenMode {
            self.enterFullScreenMode(mainScreen, withOptions: nil)
        }
        
        if coordinatesDidUpdate {
            let c = centeredCoords
            coordsLabel.stringValue = "x = \(c.x)\ny = \(c.y)"

            let (x, y) = c.toScreenCoords()
            touchCircle.removeAllPoints()
            touchCircle = NSBezierPath(ovalIn: NSRect(x: x-(touchCircleDiameter/2.0), y: y-(touchCircleDiameter/2.0), width: touchCircleDiameter, height: touchCircleDiameter))
            touchCircleColor.set()
            touchCircle.fill()
        }
        
    }
    
    
    override func touchesBegan(with event: NSEvent) {
        switch state {
        case .atOriginPoint, .touchWasCancelled:
            touch = Array(event.touches(matching: .began, in: self))[0]

            // Stick start zone - circle. Let's check it
            let c = CenteredCoords(from: touch)
            if pow(c.x, 2) + pow(c.y, 2) > pow(stickStartPositionRadius, 2) {
                touch = NSTouch()  // reset an identity
                return
            }

            currentTouch = touch
            state = .handlingTouch
            coordinatesDidUpdate = true
            self.needsDisplay = true
            coordsLabel.needsDisplay = true
        
        case .handlingTouch:
            coordinatesDidUpdate = false
        }
        
        let debugString = "Touch \(touch.identity) began at \(touch.normalizedPosition)"
        os_log(OSLogType.default, "%s", debugString)
    }
    
    override func touchesMoved(with event: NSEvent) {
        currentTouch = Array(event.touches(matching: .moved, in: self))[0]
        if currentTouch.identity.isEqual(touch.identity) {
            coordinatesDidUpdate = true
            self.needsDisplay = true
        } else {
            coordinatesDidUpdate = false
        }

        let debugString = "Touch \(currentTouch.identity) moved to \(currentTouch.normalizedPosition)"
        os_log(OSLogType.default, "%s", debugString)
    }
    
    override func touchesEnded(with event: NSEvent) {
        currentTouch = Array(event.touches(matching: .ended, in: self))[0]
        if currentTouch.identity.isEqual(touch.identity) {
            coordinatesDidUpdate = true
            state = .atOriginPoint
            self.needsDisplay = true
        } else {
            coordinatesDidUpdate = false
        }

        let debugString = "Touch \(currentTouch.identity) ended at \(currentTouch.normalizedPosition)"
        os_log(OSLogType.default, "%s", debugString)
    }
    
    // We do not expect the occurrence of this event during normal operation
    override func touchesCancelled(with event: NSEvent) {
        state = .touchWasCancelled

        let debugString = "Touch \(Array(event.touches(matching: .cancelled, in: self))[0].identity) was cancelled"
        os_log(OSLogType.error, "%s", debugString)
    }
    
    
    var centeredCoords: CenteredCoords {
        get {
            switch state {
            case .atOriginPoint:
                return CenteredCoords(x: 0.0, y: 0.0)
            case .handlingTouch:
                return CenteredCoords(from: currentTouch)
            case .touchWasCancelled:
                return CenteredCoords(x: Float32(-M_E), y: Float32(-M_E))
            }
        }
    }
    
    
    override func keyDown(with event: NSEvent) {
        if event.keyCode == 12 {  // 12 is a code of a 'Q' key
            NSCursor.unhide()
            self.exitFullScreenMode(options: nil)
            guard let parent = self.superview?.window else {
                print("No parent")
                return
            }
            parent.performClose(self)
        }
    }
    
    
    // TODO list:
    
    // [ ]   do not rely on any external UI elements - define them internally instead or remove entirely
    // [ ]   animate using Core Animation
    // [x]   configuration: on/off logs
    // [x]   coordinates getter
    // [x]   add methods for converting coordinates (for drawing and other tasks)
    // [x]   add reset to zero position after releasing the stick
    // [x]   add start (zero) zone (set as radius around (0.0, 0.0))
    
}
