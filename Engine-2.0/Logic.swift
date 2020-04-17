//
//  WorldLogic.swift
//  Engine-2.0
//
//  Created by Benjamin M. Pringle on 4/16/20.
//  Copyright © 2020 Benjamin M. Pringle. All rights reserved.
//

import Foundation

class Logic {
    var wDown = false
    var aDown = false
    var sDown = false
    var dDown = false
    var spaceDown = false
    var shiftDown = false
    
    func gameTick(renderer: Renderer) {
        print(renderer.eye.pos)
        if(wDown) {
            renderer.eye.pos[2] = renderer.eye.pos[2]+0.02
        }
        if(aDown) {
            renderer.eye.pos[0] = renderer.eye.pos[0]-0.02
        }
        if(sDown) {
            renderer.eye.pos[2] = renderer.eye.pos[2]-0.02
        }
        if(dDown) {
            renderer.eye.pos[0] = renderer.eye.pos[0]+0.02
        }
        if(spaceDown) {
            renderer.eye.pos[1] = renderer.eye.pos[1]+0.02
        }
        if(shiftDown) {
            renderer.eye.pos[1] = renderer.eye.pos[1]-0.02
        }
    }
}
