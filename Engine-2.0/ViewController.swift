//
//  ViewController.swift
//  Engine-2.0
//
//  Created by Benjamin M. Pringle on 4/14/20.
//  Copyright © 2020 Benjamin M. Pringle. All rights reserved.
//

import Cocoa
import MetalKit
import Carbon.HIToolbox.Events

class ViewController: NSViewController {

    var mtkView: MTKView {
        return view as! MTKView
    }
    
    var renderer: Renderer!
    var logic: Logic!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mtkView.device = MTLCreateSystemDefaultDevice()!
        mtkView.sampleCount = 8
        mtkView.colorPixelFormat = .bgra8Unorm_srgb
        mtkView.depthStencilPixelFormat = .depth32Float
        
        renderer = Renderer(mtkView: mtkView)
        logic = Logic()
        
        mtkView.delegate = renderer
        
        Timer.scheduledTimer(timeInterval: 1/60, target: self, selector: #selector(passLogic), userInfo: nil, repeats: true)
        
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) {
            guard let locWindow = self.view.window,
            NSApplication.shared.keyWindow === locWindow else { return $0 }
            
            switch($0.keyCode) {
                case UInt16(kVK_ANSI_W):
                    self.logic.wDown = true
                
                case UInt16(kVK_ANSI_S):
                    self.logic.sDown = true
                
                case UInt16(kVK_ANSI_A):
                    self.logic.aDown = true
                
                case UInt16(kVK_ANSI_D):
                    self.logic.dDown = true
                
                case UInt16(kVK_Space):
                    self.logic.spaceDown = true
                
                case UInt16(kVK_UpArrow):
                    self.logic.up = true
                
                default:
                    print($0.keyCode)
                    return $0
                }
            return nil
        }
    
        NSEvent.addLocalMonitorForEvents(matching: .keyUp) {
            guard let locWindow = self.view.window,
            NSApplication.shared.keyWindow === locWindow else { return $0 }
            
            switch($0.keyCode) {
                case UInt16(kVK_ANSI_W):
                    self.logic.wDown = false
                
                case UInt16(kVK_ANSI_S):
                    self.logic.sDown = false
                
                case UInt16(kVK_ANSI_A):
                    self.logic.aDown = false
                
                case UInt16(kVK_ANSI_D):
                    self.logic.dDown = false
                
                case UInt16(kVK_Space):
                    self.logic.spaceDown = false
                
                case UInt16(kVK_UpArrow):
                    self.logic.up = false
                
                default:
                    print($0.keyCode)
                    return $0
                }
            return nil
        }
    }

    @objc func passLogic() {
        guard let locWindow = self.view.window,
            NSApplication.shared.keyWindow === locWindow else { logic.gameTick(renderer: renderer!); return }
        
        if(NSEvent.modifierFlags.contains(NSEvent.ModifierFlags.shift)) {
            self.logic.shiftDown = true
        }else {
            self.logic.shiftDown = false
        }
        
        logic.gameTick(renderer: renderer!)
    }
    
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

