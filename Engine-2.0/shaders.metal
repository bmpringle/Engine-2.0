//
//  shaders.metal
//  Engine-2.0
//
//  Created by Benjamin M. Pringle on 4/14/20.
//  Copyright © 2020 Benjamin M. Pringle. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

vertex float4 vertex_function(const device float4 *pos [[buffer(0)]], unsigned int vid [[vertex_id]]) {
    return pos[vid];
}

fragment float4 fragment_function(float4 in [[stage_in]]) {
    return float4(1, 0, 0, 1);
}
