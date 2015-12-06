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
 triangle. However, I am not deep into Metal (or Swift) so there may be room for improvement.
 Apart from just drawing a triangle, the vertices are also rotated in a compute kernel just
 to try that out.
 */
class MyMTKView: MTKView
{
    var pipeline_state: MTLRenderPipelineState! = nil // the state constitute by shader programs
    var compute_pipeline_state: MTLComputePipelineState! = nil
    var vertex_buffer: MTLBuffer! = nil               // Buffer for on-device storage
    var library: MTLLibrary! = nil                    // Library of Metal shader functions
    let vertex_data:[Float] = [                       // Actual triangle data
        -1.0, -1.0, 0.0, 1.0,
        1.0, -1.0, 0.0, 1.0,
        0.0, 1.0, 0.0, 1.0]
    
    /// Constructor
    init(width: UInt, height: UInt)
    {
        // init MTKView - this involves creating a Metal device
        super.init(frame: CGRect(x: 0,y: 0,width: 500,height: 500), device: MTLCreateSystemDefaultDevice())
        
        library = device!.newDefaultLibrary()!
        
        // We compute the data size and create a buffer for our vertices. We copy
        // the vertices to that buffer in the same instance.
        let data_size = vertex_data.count * sizeofValue(vertex_data[0])
        vertex_buffer = device!.newBufferWithBytes(vertex_data, length: data_size, options: .CPUCacheModeWriteCombined)
        
        init_graphics_pipeline()
    }
    
    /** Initialize the graphics pipeline. This function deals with the shader functions
        used in rendering the triangle. */
    func init_graphics_pipeline()
    {
        // Create a library of metal shader functions. As far as I can tell, all the functions
        // in the metal files are simply put into this library. From the library we then
        // get the vertex and fragment shader functions.
        let vertex_func = library.newFunctionWithName("vertex_main")!
        let frag_func = library.newFunctionWithName("fragment_main")!
        
        // The code below describes the vertex layout in the buffer. Note, that
        // the code runs fine without, so it seems that the defaults are sane.
        let vertex_desc = MTLVertexDescriptor()
        vertex_desc.attributes[0].offset = 0
        vertex_desc.attributes[0].format = .Float4
        vertex_desc.attributes[0].bufferIndex = 0
        vertex_desc.layouts[0].stepFunction = .PerVertex
        vertex_desc.layouts[0].stride = 4 * sizeof(Float32)
        
        // Now, we initializat the Metal render pipeline descriptor and associate the shader
        // functions with the pipeline. We also need to set the pixel format.
        let pipeline_desc = MTLRenderPipelineDescriptor()
        pipeline_desc.vertexDescriptor = vertex_desc
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
    }
    
    /** This function rotates our vertices. This is done via a compute shader kernel. It seems that 
        tessellation and geometry shading needs to happen in compute shaders */
    func compute_pipeline()
    {
        let trans_func = library.newFunctionWithName("transform")
        let pipeline_desc = MTLComputePipelineDescriptor()
        pipeline_desc.computeFunction = trans_func
        do {
            try compute_pipeline_state = device!.newComputePipelineStateWithFunction(trans_func!)
        }
        catch {
            print("Creating compute pipeline state failed")
        }
        let command_buffer = device!.newCommandQueue().commandBuffer()
        let command_encoder = command_buffer.computeCommandEncoder()
        command_encoder.setComputePipelineState(compute_pipeline_state)
        command_encoder.setBuffer(vertex_buffer, offset: 0, atIndex: 0)
        
        let threads_per_group = MTLSize(width: 3,height: 1,depth: 1)
        let thread_groups = MTLSize(width: 1, height: 1, depth: 1)
        
        command_encoder.dispatchThreadgroups(thread_groups, threadsPerThreadgroup: threads_per_group)
        command_encoder.endEncoding()
        command_buffer.commit()
    }
    
    required convenience init(coder aDecoder: NSCoder)
    {
        self.init(width:500,height:500)
    }
    
    override func drawRect(dirtyRect: CGRect)
    {
        compute_pipeline() // Rotate triangle
        
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
