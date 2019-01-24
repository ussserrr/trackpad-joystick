//
//  ViewController.swift
//  trackpad-joystick
//
//  Created by ussserrr on 14/01/2019.
//  Copyright © 2019 ussserrr. All rights reserved.
//


import Cocoa
import Socket  // IBM-BlueSocket library (via Carthage)


class ViewController: NSViewController {

    @IBOutlet weak var trackpadJoystick: TrackpadJoystick!
    
    // TODO: [ ]   add checks for all optionals
    let sock: Socket? = try? Socket.create(family: .inet, type: .datagram, proto: .udp)
    let addr = Socket.createAddress(for: "192.168.1.238", on: 1200)
    
    var cnt = 0

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        print("Screen: \(NSScreen.main!.frame.width) x \(NSScreen.main!.frame.height)")
        
        // Dedicated thread to send joystick' coordinates
        DispatchQueue.global(qos: .utility).async { [weak self] in
            guard let self = self else {
                return
            }
            
            var inactiveStateIsSent = false
            
            func timer_handler(timer: Timer) -> Void {
                let (x, y) = self.trackpadJoystick!.centeredCoords.toCentered()
                if !inactiveStateIsSent {
                    do {
                        try self.sock!.write(from: [x, y], bufSize: 2*MemoryLayout<Float32>.size, to: self.addr!)
                        self.cnt += 1
                    } catch {
                        print(error)
                    }
                }
                if (x, y) == (0.0, 0.0) {
                    inactiveStateIsSent = true
                } else {
                    inactiveStateIsSent = false
                }
            }

            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: timer_handler)
            RunLoop.current.run()
        }
    }
    
    override func viewDidDisappear() {
        print(self.cnt)
        super.viewDidDisappear()
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    
    // TODO list:
    // [ ]   separate general TrackpadJoystick from the example (socket etc.). Maybe use Library project for this
}

