#include <metal_stdlib>
using namespace metal;

struct Vertex
{
    float4 position [[position]];
};

/** Pass through vertex function. */
vertex Vertex vertex_main(constant float4 *position [[buffer(0)]],
                          uint vid [[vertex_id]])
{
    Vertex vert;
    vert.position = position[vid];
    return vert;
}

/** Just return the color red for each fragment */
fragment float4 fragment_main(Vertex vert [[stage_in]])
{
    return float4(0,0,1,1);
}

/** simply rotate the vertex. Note that this is a kernel function. Seems Metal
 only does vertex and fragment programs, so we need to use compute shaders for 
 other things. */
kernel void transform(device float4 *pos [[buffer(0)]],
                      uint gid [[thread_position_in_grid]])
{
    float alpha(0.01);
    float4x4 m(1.0);
    m[0][0] = cos(alpha);
    m[1][0] = sin(alpha);
    m[0][1] = -sin(alpha);
    m[1][1] = cos(alpha);
    
    pos[gid] = m*pos[gid];
}