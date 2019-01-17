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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        print("Screen: \(NSScreen.main!.frame.width) x \(NSScreen.main!.frame.height)")
        
        let sock = try? Socket.create(family: .inet, type: .datagram, proto: .udp)
        let addr = Socket.createAddress(for: "192.168.1.222", on: 1200)
        let len = try? sock!.write(from: "Hello, World!", to: addr!)
        sock!.close()
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

