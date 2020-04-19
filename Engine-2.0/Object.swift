//
//  Object.swift
//  Engine-2.0
//
//  Created by Benjamin M. Pringle on 4/17/20.
//  Copyright © 2020 Benjamin M. Pringle. All rights reserved.
//

import Foundation

class Object {
    var vertices: [Vertex]?
    var name: String
    var xyz: SIMD3<Float> = SIMD3<Float>(0, 0, 0)
    
    init(vertices: [Vertex]?, name: String) {
        self.vertices = vertices
        self.name = name
    }
    
    func getVertices() -> [Vertex] {
        var v = vertices!
        
        for i in 0..<v.count {
            v[i].pos = SIMD4<Float>(v[i].pos[0]+xyz[0], v[i].pos[1]+xyz[1], v[i].pos[2]+xyz[2], v[i].pos[3])
        }
        
        return v
    }
    
    func move(xyz: SIMD3<Float>) {
        self.xyz+=xyz
    }
    
    static func objToObject(path: String, color: SIMD4<Float>) -> [Vertex] {
        let url = Bundle.main.url(forResource: path, withExtension: ".obj")!
        let text = try! String(contentsOf: url)
        
        let lines = text.split(separator: "\n")
        
        var vertsS = [String]()
        var facesS = [String]()
        
        var verts = [SIMD3<Float>]()
        var triangles = [Vertex]()
        
        for i in lines {
            if(String(String(i).substring(to: String.Index(encodedOffset: 1))) == "v" || String(String(i).substring(to: String.Index(encodedOffset: 1))) == "f") {
                if(String(String(i).substring(to: String.Index(encodedOffset: 2))) != "vn") {
                    if(String(String(i).substring(to: String.Index(encodedOffset: 1))) == "v") {
                        vertsS.append(String(i).substring(from: String.Index(encodedOffset: 2)))
                    }else {
                        facesS.append(String(i).substring(from: String.Index(encodedOffset: 2)))
                    }
                }
            }
        }
        
        for i in vertsS {
            let lines = i.split(separator: " ")
            verts.append(SIMD3<Float>(Float(lines[0])!, Float(lines[1])!, Float(lines[2])!))
        }
        
        for i in facesS {
            var vertsMakeFace = [SIMD3<Float>]()
            
            let vsString = i.split(separator: " ")
            
            for i in vsString {
                vertsMakeFace.append(verts[Int(String(i.split(separator: "/")[0]))!-1])
            }
            
            let startVert = vertsMakeFace[0]
            var lB = 1
            while(lB < vertsMakeFace.count-1) {
                triangles.append(Vertex(pos: SIMD4<Float>(startVert, 1), color: color))
                triangles.append(Vertex(pos: SIMD4<Float>(vertsMakeFace[lB], 1), color: color))
                triangles.append(Vertex(pos: SIMD4<Float>(vertsMakeFace[lB+1], 1), color: color))
                lB+=1
            }
        }
        
        return triangles
    }
}
