# SwiftMetalOSXHelloTriangle

Hello Triangle in Swift, using Metal for OSX.

Apple's examples for Metal appear to be mostly in Obj-C, and the Swift metal examples found online are mostly for iOS or - in some cases - just a bit too big for my taste. This 
project is as close as I managed to come to a program that only draws a single triangle. I drew on many sources of inspiration: Apple's examples and WWDC videos, a video by Warren Moore, the particle lab example and Ray Wenderlich's tutorials and other online material.

Apart from simply drawing the triangle, the program also rotates the triangle. This is done in a compute kernel which is set up in a separate function, so it does not add much complexity to the example.

Being a complete novice both with regard to Swift and to Metal, I cannot guarantee that this example does everything in the best possible way. 

The program relies on MetalKit. This seems to be an important library which simplifies both creating a metal window and getting assets into the program.

/Andreas 