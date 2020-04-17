//
//  Renderer.swift
//  Engine-2.0
//
//  Created by Benjamin M. Pringle on 4/14/20.
//  Copyright © 2020 Benjamin M. Pringle. All rights reserved.
//

import Foundation
import MetalKit

class Renderer: NSObject, MTKViewDelegate {
    
    var mtkView: MTKView!
    var device: MTLDevice!
    var renderPipelineState: MTLRenderPipelineState!
    var commandQueue: MTLCommandQueue!
    var eye = Eye(pos: SIMD3<Float>(0, 0, 0))
    var constants: Constants!
    var depthStencilState: MTLDepthStencilState!
    
    var verts = [
        
        float8(pos: SIMD4<Float>(-1, -1, -1, 1), color: SIMD4<Float>(1, 1, 0, 1)),
        float8(pos: SIMD4<Float>(-1, -1, 1, 1), color: SIMD4<Float>(1, 1, 0, 1)),
        float8(pos: SIMD4<Float>(-1, 1, 1, 1), color: SIMD4<Float>(1, 1, 0, 1)),
        
        float8(pos: SIMD4<Float>(-1, -1, -1, 1), color: SIMD4<Float>(1, 1, 0, 1)),
        float8(pos: SIMD4<Float>(-1, 1, -1, 1), color: SIMD4<Float>(1, 1, 0, 1)),
        float8(pos: SIMD4<Float>(-1, 1, 1, 1), color: SIMD4<Float>(1, 1, 0, 1)),
        
        
        float8(pos: SIMD4<Float>(1, -1, -1, 1), color: SIMD4<Float>(0, 1, 0, 1)),
        float8(pos: SIMD4<Float>(1, -1, 1, 1), color: SIMD4<Float>(0, 1, 0, 1)),
        float8(pos: SIMD4<Float>(1, 1, 1, 1), color: SIMD4<Float>(0, 1, 0, 1)),
        
        float8(pos: SIMD4<Float>(1, -1, -1, 1), color: SIMD4<Float>(0, 1, 0, 1)),
        float8(pos: SIMD4<Float>(1, 1, -1, 1), color: SIMD4<Float>(0, 1, 0, 1)),
        float8(pos: SIMD4<Float>(1, 1, 1, 1), color: SIMD4<Float>(0, 1, 0, 1)),
        
        
        float8(pos: SIMD4<Float>(-1, -1, 1, 1), color: SIMD4<Float>(0, 1, 1, 1)),
        float8(pos: SIMD4<Float>(1, -1, 1, 1), color: SIMD4<Float>(0, 1, 1, 1)),
        float8(pos: SIMD4<Float>(-1, 1, 1, 1), color: SIMD4<Float>(0, 1, 1, 1)),
        
        float8(pos: SIMD4<Float>(1, -1, 1, 1), color: SIMD4<Float>(0, 1, 1, 1)),
        float8(pos: SIMD4<Float>(-1, 1, 1, 1), color: SIMD4<Float>(0, 1, 1, 1)),
        float8(pos: SIMD4<Float>(1, 1, 1, 1), color: SIMD4<Float>(0, 1, 1, 1)),
        
        
        float8(pos: SIMD4<Float>(-1, 1, -1, 1), color: SIMD4<Float>(1, 0, 1, 1)),
        float8(pos: SIMD4<Float>(1, 1, -1, 1), color: SIMD4<Float>(1, 0, 1, 1)),
        float8(pos: SIMD4<Float>(1, 1, 1, 1), color: SIMD4<Float>(1, 0, 1, 1)),
        
        float8(pos: SIMD4<Float>(-1, 1, -1, 1), color: SIMD4<Float>(1, 0, 1, 1)),
        float8(pos: SIMD4<Float>(-1, 1, 1, 1), color: SIMD4<Float>(1, 0, 1, 1)),
        float8(pos: SIMD4<Float>(1, 1, 1, 1), color: SIMD4<Float>(1, 0, 1, 1)),
        
        
        float8(pos: SIMD4<Float>(-1, -1, -1, 1), color: SIMD4<Float>(1, 1, 1, 1)),
        float8(pos: SIMD4<Float>(1, -1, -1, 1), color: SIMD4<Float>(1, 1, 1, 1)),
        float8(pos: SIMD4<Float>(1, -1, 1, 1), color: SIMD4<Float>(1, 1, 1, 1)),
        
        float8(pos: SIMD4<Float>(-1, -1, -1, 1), color: SIMD4<Float>(1, 1, 1, 1)),
        float8(pos: SIMD4<Float>(-1, -1, 1, 1), color: SIMD4<Float>(1, 1, 1, 1)),
        float8(pos: SIMD4<Float>(1, -1, 1, 1), color: SIMD4<Float>(1, 1, 1, 1)),
      
        float8(pos: SIMD4<Float>(-1, -1, -1, 1), color: SIMD4<Float>(1, 0, 0, 1)),
        float8(pos: SIMD4<Float>(1, -1, -1, 1), color: SIMD4<Float>(1, 0, 0, 1)),
        float8(pos: SIMD4<Float>(-1, 1, -1, 1), color: SIMD4<Float>(1, 0, 0, 1)),
        
        float8(pos: SIMD4<Float>(1, -1, -1, 1), color: SIMD4<Float>(1, 0, 0, 1)),
        float8(pos: SIMD4<Float>(-1, 1, -1, 1), color: SIMD4<Float>(1, 0, 0, 1)),
        float8(pos: SIMD4<Float>(1, 1, -1, 1), color: SIMD4<Float>(1, 0, 0, 1)),
        
    ]
    
    init(mtkView: MTKView) {
        super.init()
        self.mtkView = mtkView
        device = mtkView.device!
        constants = Constants(bounds: SIMD3<Float>(10, 10, 20), aspectRatio: SIMD2<Float>(Float(mtkView.bounds.width), Float(mtkView.bounds.height)))
        renderPipelineState = createRenderPipelineState()
        commandQueue = device.makeCommandQueue()!
        depthStencilState = buildDepthStencilState(device: device)
    }
    
    func buildDepthStencilState(device: MTLDevice) -> MTLDepthStencilState {
        let depthStencilDescriptor = MTLDepthStencilDescriptor()
        depthStencilDescriptor.depthCompareFunction = .less
        depthStencilDescriptor.isDepthWriteEnabled = true
        return device.makeDepthStencilState(descriptor: depthStencilDescriptor)!
    }
    
    func createRenderPipelineState() -> MTLRenderPipelineState {
        let desc = MTLRenderPipelineDescriptor()
        let lib = device.makeDefaultLibrary()
        desc.vertexFunction = lib?.makeFunction(name: "vertex_function")!
        desc.fragmentFunction = lib?.makeFunction(name: "fragment_function")!
        desc.sampleCount = mtkView.sampleCount
        desc.depthAttachmentPixelFormat = mtkView.depthStencilPixelFormat
        // Setup the output pixel format to match the pixel format of the metal kit view
        desc.colorAttachments[0].pixelFormat = mtkView.colorPixelFormat
        desc.colorAttachments[0].isBlendingEnabled = true
        desc.colorAttachments[0].rgbBlendOperation = .add
        desc.colorAttachments[0].alphaBlendOperation = .add
        desc.colorAttachments[0].sourceRGBBlendFactor = .one
        desc.colorAttachments[0].sourceAlphaBlendFactor = .sourceAlpha
        desc.colorAttachments[0].destinationRGBBlendFactor = .oneMinusSourceAlpha
        desc.colorAttachments[0].destinationAlphaBlendFactor = .oneMinusSourceAlpha
        return try! device.makeRenderPipelineState(descriptor: desc)
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        
    }
    
    func draw(in view: MTKView) {
        let cBuf = commandQueue.makeCommandBuffer()!
        let encoder = cBuf.makeRenderCommandEncoder(descriptor: view.currentRenderPassDescriptor!)!
        
        let mtlBufferVertex = device.makeBuffer(bytes: verts, length: MemoryLayout<float8>.stride*verts.count, options: [])!
        let mtlConstantsBuffer = device.makeBuffer(length: 32, options: [])!
        let mtlEyeBuffer = device.makeBuffer(length: MemoryLayout<Eye>.size, options: [])!
        
        memcpy(mtlConstantsBuffer.contents(), &constants, MemoryLayout<Constants>.size)
        memcpy(mtlEyeBuffer.contents(), &eye, MemoryLayout<Eye>.size)
        
        encoder.setRenderPipelineState(renderPipelineState)
        encoder.setDepthStencilState(depthStencilState)
        encoder.setVertexBuffer(mtlBufferVertex, offset: 0, index: 0)
        encoder.setVertexBuffer(mtlConstantsBuffer, offset: 0, index: 1)
        encoder.setVertexBuffer(mtlEyeBuffer, offset: 0, index: 2)
        encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: verts.count)
        encoder.endEncoding()
        cBuf.present(view.currentDrawable!)
        cBuf.commit()
    }
    
    @objc func test() {
        verts = rotate90(a: verts)
    }
    
    func rotate90(a: [float8]) -> [float8] {
        var n = [float8]()
        for i in a {
            var n_1: float8 = float8(pos: SIMD4<Float>(0, 0, 0, 0), color: SIMD4<Float>(0, 0, 0, 0))
            n_1.pos = SIMD4<Float>(-i.pos[2], i.pos[1], i.pos[0], i.pos[3])
            n_1.color = i.color
            n.append(n_1)
        }
        return n
    }
}
