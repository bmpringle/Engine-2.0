//
//  ViewController.swift
//  Engine-2.0
//
//  Created by Benjamin M. Pringle on 4/14/20.
//  Copyright © 2020 Benjamin M. Pringle. All rights reserved.
//

import Cocoa
import MetalKit

class ViewController: NSViewController {

    var mtkView: MTKView {
        return view as! MTKView
    }
    
    var renderer: Renderer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mtkView.device = MTLCreateSystemDefaultDevice()!
        mtkView.sampleCount = 8
        mtkView.colorPixelFormat = .bgra8Unorm_srgb
        mtkView.depthStencilPixelFormat = .depth32Float
        
        renderer = Renderer(mtkView: mtkView)
        mtkView.delegate = renderer
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

