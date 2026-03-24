import CoreGraphics
import Foundation

@Observable
class RenderModel: AlgorithmModel {
    var width = 960
    var height = 540
    
    var obj: String = "tinker"
    var mtl: String = "obj"
    
    var triangles: [Triangle] = []
    var loaded = false
    
    var x: Float = -200
    var y: Float = 60
    var z: Float = -390
    
    let tileSize: Int = 48
    var angleX: Float = Float.pi * 0.4
    var angleY: Float = 0.1
    var angleZ: Float = (-Float.pi / 3) + 3.4
    
    var fov = Float.pi / 3
    let zNear: Float = 0.1
    let zFar: Float = 10000
    
    var frameBuffer: [Int]
    
    init(_ width: Int, _ height: Int) {
        frameBuffer = [Int](repeating: 0, count: width * height)
        
        super.init()
        
        self.width = width
        self.height = height
        
        for i in 0..<frameBuffer.count {
            frameBuffer[i] = 0xFF0000FF
        }
    }
    
    func reset() {
        currentTask?.cancel()
        for i in 0..<frameBuffer.count {
            frameBuffer[i] = 0xFF0000FF
        }
    }
    
    func loadAsync() async {
        triangles = await load3dModel(obj, mtl)
        loaded = true
        print("loaded")
    }
    
    func makeImage() -> CGImage? {
        var data = frameBuffer
        
        let context = CGContext(
            data: &data,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: width * MemoryLayout<Int>.size,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        )
        
        return context?.makeImage()
    }
}
