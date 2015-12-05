//
//  MyMTKView.swift
//  MetallicSwift
//
//  Created by J. Andreas Bærentzen on 02/12/2015.
//  Copyright © 2015 J. Andreas Bærentzen. All rights reserved.
//

import Metal
import MetalKit

/** MTKView supposedly greatly simplifies creating Metal applications.
    This is my best shot at the simplest possible metal based swift program that draws a 
    triangle. However, I am not deep into Metal (or Swift) so there may be room for improvement */
class MyMTKView: MTKView
{
    var pipeline_state: MTLRenderPipelineState! = nil // the state constitute by shader programs
    var vertex_buffer: MTLBuffer! = nil               // Buffer for on-device storage
    let vertex_data:[Float] = [                       // Actual triangle data
        -1.0, -1.0, 0.0,
        1.0, -0.9, 0.0,
        1.0, 1.0, 0.0]
    
    /// Constructor
    init(width: UInt, height: UInt)
    {
        // init MTKView - this involves creating a Metal device
        super.init(frame: CGRect(x: 0,y: 0,width: 500,height: 500), device: MTLCreateSystemDefaultDevice())
        
        // Create a library of metal shader functions. As far as I can tell, all the functions
        // in the metal files are simply put into this library. From the library we then 
        // get the vertex and fragment shader functions.
        let library = device!.newDefaultLibrary()!
        let vertex_func = library.newFunctionWithName("vertex_main")!
        let frag_func = library.newFunctionWithName("fragment_main")!
        
        // Now, we initializat the Metal render pipeline descriptor and associate the shader
        // functions with the pipeline. We also need to set the pixel format.
        let pipeline_desc = MTLRenderPipelineDescriptor()
        pipeline_desc.vertexFunction = vertex_func
        pipeline_desc.fragmentFunction = frag_func
        pipeline_desc.colorAttachments[0].pixelFormat = .BGRA8Unorm
        
        // The pipeline descriptor is now used to create a pipeline state object. The precise
        // difference between the descriptor and the state is a bit hazy to me.
        do {
            try pipeline_state = device!.newRenderPipelineStateWithDescriptor(pipeline_desc)
        }
        catch {
            print("Creating pipeline state failed")
        }
        
        // Finally, we compute the data size and create a buffer for our vertices. We copy
        // the vertices to that buffer in the same instance.
        let data_size = vertex_data.count * sizeofValue(vertex_data[0])
        vertex_buffer = device!.newBufferWithBytes(vertex_data, length: data_size, options: .CPUCacheModeWriteCombined)
        
    }
    
    required convenience init(coder aDecoder: NSCoder)
    {
        self.init(width:500,height:500)
    }
    
    override func drawRect(dirtyRect: CGRect)
    {
        // So, drawing is contingent on a valid drawable being available. We cannot retrieve
        // the drawable in the initialization. So, the things that need the drawable are here in
        // the drawRect function.
        if let drawable = currentDrawable {
            
            // First we  create a render pass descriptor which encapsulates the frame buffer 
            // information. This is also provided by MTKView
            if let pass_descriptor = currentRenderPassDescriptor {
                pass_descriptor.colorAttachments[0].clearColor = MTLClearColorMake(0.8, 0.0, 0.0, 1.0)
                
                // Next, we create the command buffer, queue, and encoder. These objects together
                // encapsulate the actual submission of graphics commands to the GPU.
                let command_buffer = device!.newCommandQueue().commandBuffer()
                let command_encoder = command_buffer.renderCommandEncoderWithDescriptor(pass_descriptor)
                
                command_encoder.setRenderPipelineState(pipeline_state)
                command_encoder.setVertexBuffer(vertex_buffer, offset: 0, atIndex: 0)
                command_encoder.drawPrimitives(.Triangle, vertexStart: 0, vertexCount: 3, instanceCount: 1)
                command_encoder.endEncoding()
                command_buffer.presentDrawable(drawable)
                command_buffer.commit()
            }
        }
    }
    
}
