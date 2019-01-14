//
//  ViewController.swift
//  trackpad-joystick
//
//  Created by Андрей Чуфырев on 14/01/2019.
//  Copyright © 2019 ussserrr. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet weak var trackpadJoystick: TrackpadJoystick!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        print("\(NSScreen.main!.frame.width) x \(NSScreen.main!.frame.height)")
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

