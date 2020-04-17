//
//  Constants.swift
//  Engine-2.0
//
//  Created by Benjamin M. Pringle on 4/15/20.
//  Copyright © 2020 Benjamin M. Pringle. All rights reserved.
//

import Foundation
import simd

struct Constants {
    var bounds: SIMD3<Float>
    var aspectRatio: SIMD2<Float>
}

struct Eye {
    var pos: SIMD3<Float>
}

struct float8 {
    var pos: SIMD4<Float>
    var color: SIMD4<Float>
}
