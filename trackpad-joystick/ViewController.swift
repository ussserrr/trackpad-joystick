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
        
        print("Screen: \(NSScreen.main!.frame.width) x \(NSScreen.main!.frame.height)")
        
        // Dedicated thread to send joystick' coordinates
        DispatchQueue.global(qos: .utility).async { [weak self] in
            guard let self = self else {
                return
            }
            
            func timer_handler(timer: Timer) -> Void {
                if let c = self.trackpadJoystick.coords {
                    do {
                        try self.sock!.write(from: [c.x, c.y], bufSize: 2*4, to: self.addr!)
                    } catch {
                        print(error)
                    }
                }
            }

            let t = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: timer_handler)
            RunLoop.current.run()
        }
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    

}

