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
    
    init(mtkView: MTKView) {
        super.init()
        
        self.mtkView = mtkView
        device = mtkView.device!
        renderPipelineState = createRenderPipelineState()
        commandQueue = device.makeCommandQueue()!
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
        encoder.setRenderPipelineState(renderPipelineState)
        
        let verts = [
            SIMD4<Float>(-1, -1, 1, 1),
            SIMD4<Float>(0, 1, 1, 1),
            SIMD4<Float>(1, -1, 1, 1)
        ]
        
        let mtlBufferVertex = device.makeBuffer(bytes: verts, length: MemoryLayout<SIMD4<Float>>.stride*verts.count, options: [])!
        encoder.setVertexBuffer(mtlBufferVertex, offset: 0, index: 0)
        encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: verts.count)
        encoder.endEncoding()
        cBuf.present(view.currentDrawable!)
        cBuf.commit()
    }
    
    
}
