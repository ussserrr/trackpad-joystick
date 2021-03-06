//
//  ViewController.swift
//  trackpad-joystick
//
//  Created by ussserrr on 14/01/2019.
//  Copyright © 2019 ussserrr. All rights reserved.
//


import Cocoa
import os
import Socket  // IBM-BlueSocket library (via Carthage)


class ViewController: NSViewController {

    @IBOutlet weak var trackpadJoystick: TrackpadJoystick?
    
    let sock: Socket? = try? Socket.create(family: .inet, type: .datagram, proto: .udp)
    let addr: Socket.Address? = Socket.createAddress(for: "192.168.1.238", on: 1200)
    
    var joystickTimer = Timer()
    
    var pointsWereSentCounter = 0

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Unwrap the optionals
        guard let sock = self.sock else {
            os_log(OSLogType.fault, "Cannot create a socket")
            return
        }
        guard let addr = self.addr else {
            os_log(OSLogType.fault, "Cannot create an address")
            return
        }
        guard let trackpadJoystick = self.trackpadJoystick else {
            os_log(OSLogType.fault, "No TrackpadJoystick instance is present")
            return
        }
        
        // Dedicated thread to send joystick' coordinates
        DispatchQueue.global(qos: .utility).async { [weak self] in
            guard let self = self else {
                return
            }
            
            var inactiveStateIsSent = false
            
            func timer_handler(timer: Timer) -> Void {
                if !inactiveStateIsSent {
                    let c = trackpadJoystick.centeredCoords
                    do {
                        try sock.write(from: [c.x, c.y], bufSize: 2*MemoryLayout<Float32>.size, to: addr)
                        self.pointsWereSentCounter += 1
                    } catch {
                        // Need this as error.localizedDescription doesn't contain useful information
                        let errorString = "\(error)"
                        os_log(OSLogType.error, "%s", errorString)
                        return
                    }
                }
                inactiveStateIsSent = trackpadJoystick.state == .atOriginPoint ? true : false
            }

            self.joystickTimer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true, block: timer_handler)
            RunLoop.current.run()
        }
    }
    
    
    override func viewDidDisappear() {
        
        self.joystickTimer.invalidate()
        os_log(OSLogType.debug, "Points sent: %d", self.pointsWereSentCounter)

        // Unwrap the optionals
        guard let sock = self.sock else {
            os_log(OSLogType.error, "Socket is invalid")
            return
        }
        guard let addr = self.addr else {
            os_log(OSLogType.error, "Address is invalid")
            return
        }

        let c = CenteredCoords(x: 0.0, y: 0.0)
        for _ in 0..<10 {  // tries to attempt
            do {
                try sock.write(from: [c.x, c.y], bufSize: 2*MemoryLayout<Float32>.size, to: addr)
                break
            } catch {
                // Need this as error.localizedDescription doesn't contain useful information
                let errorString = "\(error)"
                os_log(OSLogType.error, "%s", errorString)
                continue
            }
        }
        sock.close()

        super.viewDidDisappear()
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    

}

