//
//  ViewController.swift
//  trackpad-joystick
//
//  Created by ussserrr on 14/01/2019.
//  Copyright © 2019 ussserrr. All rights reserved.
//


import Cocoa
import Socket


class ViewController: NSViewController {

    @IBOutlet weak var trackpadJoystick: TrackpadJoystick!
    
    let sock: Socket? = try? Socket.create(family: .inet, type: .datagram, proto: .udp)
    let addr = Socket.createAddress(for: "192.168.1.222", on: 1200)

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let t = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: self.timer_handler)
//        t.tolerance = 0.01
//        let t = Timer.init(timeInterval: 0.1, repeats: true, block: self.timer_handler)
//        RunLoop.main.add(t, forMode: .common)

        print("Screen: \(NSScreen.main!.frame.width) x \(NSScreen.main!.frame.height)")
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    func timer_handler(timer: Timer) -> Void {
        if let c = trackpadJoystick.coords {
            do {
                try sock!.write(from: [c.x, c.y], bufSize: 2*4, to: addr!)
            } catch {
                print(error)
            }
        }
    }


}

