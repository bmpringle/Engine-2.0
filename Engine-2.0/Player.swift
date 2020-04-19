//
//  Player.swift
//  Engine-2.0
//
//  Created by Benjamin M. Pringle on 4/17/20.
//  Copyright © 2020 Benjamin M. Pringle. All rights reserved.
//

import Foundation

class Player: Object {
    var eye = Eye(pos: SIMD3<Float>(0, 0, 0))
    
    init(vertices: [Vertex]?, name: String, thirdperson: Bool) {
        if(thirdperson) {
            eye.pos+=SIMD3<Float>(4, 6, -15)
        }
        super.init(vertices: vertices, name: name)
    }
    
    override func move(xyz: SIMD3<Float>) {
        self.xyz+=xyz
        self.eye.pos+=xyz
    }
}
