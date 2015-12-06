# SwiftMetalOSXHelloTriangle

This is simply Hello Triangle in Swift, using Metal for OSX.

Apple's examples for Metal appear to be mostly in Obj-C and the Swift metal examples, 
I have otherwise found online are mostly for iOS or a bit more of a mouthful. So, this is 
the smallest program that I managed to write that only draws a single triangle. I drew on many sources of inspiration: Apple's examples and WWDC videos, a video by Warren Moore, the particle lab example and Ray Wenderlich's tutorials. Anything I could find online.

Apart from simply drawing the triangles, I also use a compute kernel to rotate the triangle.
This is done in a compute kernel which is set up in a separate function, so it does not add
much complexity to the example.

Being a complete novice both with regard to Swift and to Metal, I cannot guarantee that this example does everything in the best possible way. 

Anyways, the program relies on MetalKit. This seems to be an important library which simplifies both creating a metal window and getting assets into the program.

/Andreas 