//
//  shaders.metal
//  Engine-2.0
//
//  Created by Benjamin M. Pringle on 4/14/20.
//  Copyright © 2020 Benjamin M. Pringle. All rights reserved.
//

#include <metal_stdlib>

using namespace metal;

struct Constants {
    float3 bounds;
    float2 aspectRatio;
};

struct Eye {
    float3 eye;
};

struct Float8 {
    float4 pos [[position]];
    float4 color;
};

vertex Float8 vertex_function(const device Float8 *pos [[buffer(0)]], const device Constants *constants [[buffer(1)]], const device Eye *eye [[buffer(2)]], unsigned int vid [[vertex_id]]) {
    
    Float8 vertex_ = pos[vid];
    
    Float8 ndcSpace;
    ndcSpace.pos = float4(vertex_.pos[0]/constants->bounds[0], vertex_.pos[1]/constants->bounds[1], vertex_.pos[2]/constants->bounds[2], vertex_.pos[3]);
    ndcSpace.color = vertex_.color;
    
    Eye ndcEye;
    ndcEye.eye = float3(eye->eye[0]/constants->bounds[0], eye->eye[1]/constants->bounds[1], eye->eye[2]/constants->bounds[2]);
    
    float aspectRatio = constants->aspectRatio[0]/constants->aspectRatio[1];
    
    Float8 eyeSpace;
    eyeSpace.pos = float4(ndcSpace.pos[0]-ndcEye.eye[0], (ndcSpace.pos[1]-ndcEye.eye[1])*aspectRatio, ndcSpace.pos[2]-ndcEye.eye[2], ndcSpace.pos[3]);
    eyeSpace.color = ndcSpace.color;
    
    Float8 clipSpace;
    clipSpace.pos = float4(eyeSpace.pos[0]/eyeSpace.pos[2], eyeSpace.pos[1]/eyeSpace.pos[2], eyeSpace.pos[2], eyeSpace.pos[3]);
    clipSpace.color = eyeSpace.color;
    
    return clipSpace;
}

fragment float4 fragment_function(Float8 in [[stage_in]]) {
    return in.color;
}
