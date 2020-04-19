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
    var up = false
    var GPS = 0.1
    var velocity = SIMD3<Float>(0, 0, 0)
    var player: Player
    var objects = [Object]()
    var walkSpeed: Float = 1/15;
    var runSpeed: Float = 2
    var maxSpeed: Float = 3
    
    init() {
        player = Player(vertices: Object.objToObject(path: "player", color: SIMD4<Float>(1, 0.5, 1, 1)), name: "player", thirdperson: true)
        player.move(xyz: SIMD3<Float>(0, 3, 0))
        objects.append(Object(vertices: Renderer.verts, name: "boxocolors"))
        objects[0].move(xyz: SIMD3<Float>(0, 0, 0))
        objects.append(Object(vertices: Renderer.verts, name: "boxocolors2"))
        objects[1].move(xyz: SIMD3<Float>(4, 0, 6))
    }
    
    func gameTick(renderer: Renderer) {
        
        renderer.polygonsToRender = [[Vertex]]()
        
        for i in objects {
            renderer.polygonsToRender.append(i.getVertices())
        }
        
        //check for floor
        var falling = true
        
        //bottom of world
        if(renderer.eye.pos[1] <= -renderer.constants.bounds[1]) {
            renderer.eye.pos[1] = -renderer.constants.bounds[1]
            velocity[1] = 0
            falling = false
        }
        
        //check for collision with ground.
        for i in objects {
            for k in 0..<4 {
                var PMOD = SIMD3<Float>(0, 0, 0)
                switch(k) {
                    case 1:
                        PMOD+=SIMD3<Float>(-1, 0, 1)
                    case 2:
                        PMOD+=SIMD3<Float>(-1, 0, -1)
                    case 3:
                        PMOD+=SIMD3<Float>(1, 0, -1)
                    default:
                        PMOD = SIMD3<Float>(1, 0, 1)
                }
                for j in 0..<i.getVertices().count/3 {
                    let A = i.getVertices()[3*j]
                    let B = i.getVertices()[3*j+1]
                    let C = i.getVertices()[3*j+2]
                    let P = player.xyz + PMOD
                    
                    if(pointInTriangle(pt: SIMD2<Float>(P[0], P[2]), v1: SIMD2<Float>(A.pos[0], A.pos[2]), v2: SIMD2<Float>(B.pos[0], B.pos[2]), v3: SIMD2<Float>(C.pos[0], C.pos[2]))) {
                        
                        let BA = SIMD3<Float>((B.pos-A.pos)[0], (B.pos-A.pos)[1], (B.pos-A.pos)[2])
                        let CA = SIMD3<Float>((C.pos-A.pos)[0], (C.pos-A.pos)[1], (C.pos-A.pos)[2])
                        
                        let normalV = crossProduct(a: BA, b: CA)
                        
                        //equation of the plane is ax+by+cz=d
                        let a = normalV[0]
                        let b = normalV[1]
                        let c = normalV[2]
                        let d = a*A.pos[0]+b*A.pos[1]+c*A.pos[2]
                         
                        let lineX = player.xyz[0]
                        let lineZ = player.xyz[2]
                        
                        let lineY = (d-a*lineX-c*lineZ)/b
                        
                        if((player.xyz[1]+(velocity[1]-Float(GPS/60)) < lineY) && player.xyz[1] >= lineY) {
                            player.xyz[1] = lineY
                            falling = false
                        }else {
    
                        }
                    }
                }
            }
        }
        //handle falling
        if(!falling) {
            velocity[1] = 0
        }else {
            velocity[1] = velocity[1]-Float(GPS/60)
        }
        
        //make it so that only my y coordinate for the player uses thrust
        velocity = SIMD3<Float>(0, velocity[1], 0)
        
        if(wDown && velocity[2] < maxSpeed) {
            velocity[2] = walkSpeed
        }
        
        if(aDown && velocity[0] > -maxSpeed) {
            velocity[0] = -walkSpeed
        }
        
        if(sDown && velocity[2] > -maxSpeed) {
            velocity[2] = -walkSpeed
        }
        
        if(dDown && velocity[0] < maxSpeed) {
            velocity[0] = walkSpeed
        }
        
        if(spaceDown && velocity[1] < maxSpeed && !falling) {
            velocity[1] = walkSpeed
        }
        
        if(shiftDown && velocity[1] > -maxSpeed) {
            velocity[1] = -walkSpeed
        }
        
        if(up) {
            renderer.addOneToVertex()
        }
        
        player.move(xyz: velocity)
        renderer.polygonsToRender.append(player.getVertices())
        renderer.eye = player.eye
    }
    
    func sign (_ p1: SIMD2<Float>, _ p2: SIMD2<Float>, _ p3: SIMD2<Float>) -> Float {
        return (p1[0] - p3[0]) * (p2[1] - p3[1]) - (p2[0] - p3[0]) * (p1[1] - p3[1]);
    }

    func pointInTriangle (pt: SIMD2<Float>, v1: SIMD2<Float>, v2: SIMD2<Float>, v3: SIMD2<Float>) -> Bool {
        var d1: Float
        var d2: Float
        var d3: Float
        var has_neg: Bool
        var has_pos: Bool

        d1 = sign(pt, v1, v2)
        d2 = sign(pt, v2, v3)
        d3 = sign(pt, v3, v1)

        has_neg = (d1 < 0) || (d2 < 0) || (d3 < 0)
        has_pos = (d1 > 0) || (d2 > 0) || (d3 > 0)

        return !(has_neg && has_pos);
    }
    
    func crossProduct(a:  SIMD3<Float>, b: SIMD3<Float>) -> SIMD3<Float> {
        let x: Float = a[1]*b[2]-a[2]*b[1]
        let y: Float = a[2]*b[0]-a[0]*b[2]
        let z: Float = a[0]*b[1]-a[1]*b[0]
        return SIMD3<Float>(x, y, z)
    }
}
