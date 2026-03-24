import Darwin
import Foundation

struct IntVec2 {
    var x: Int
    var y: Int
}

struct Vec3 {
    var x: Float
    var y: Float
    var z: Float
}

func -(lhs: Vec3, rhs: Vec3) -> Vec3 {
    return Vec3(
        x: lhs.x - rhs.x,
        y: lhs.y - rhs.y,
        z: lhs.z - rhs.z
    )
}

func cross(_ a: Vec3, _ b: Vec3) -> Vec3 {
    return Vec3(
        x: a.y * b.z - a.z * b.y,
        y: a.z * b.x - a.x * b.z,
        z: a.x * b.y - a.y * b.x
    )
}

struct Vec4 {
    var x: Float
    var y: Float
    var z: Float
    var w: Float
}

struct Mat4 {
    var m: [Float] = Array(repeating: 0, count: 16)
    
    // Inicializador identidade
    init(identity: Bool = false) {
        if identity {
            m[0] = 1
            m[5] = 1
            m[10] = 1
            m[15] = 1
        }
    }
}

struct Triangle {
    var v0: Vec3
    var v1: Vec3
    var v2: Vec3
    var normal: Vec3
    var color: Int
}

struct ClipedTriangle {
    var v0: IntVec2
    var v1: IntVec2
    var v2: IntVec2
    
    var normal: Vec4

    var z0: Float
    var z1: Float
    var z2: Float

    var color: Int
}

// 3D Linear Algebra
func cross2D(_ a: IntVec2, _ b: IntVec2, _ p: IntVec2) -> Int {
    let ab: IntVec2 = IntVec2(x: b.x - a.x, y: b.y - a.y)
    let ap: IntVec2 = IntVec2(x: p.x - a.x, y: p.y - a.y)
    return ab.x * ap.y - ab.y * ap.x
}

func normalize(_ v: Vec3) -> Vec3 {
    let length: Float = sqrtf(v.x * v.x + v.y * v.y + v.z * v.z)
    
    if length < 1e-4 {return v}
    
    return Vec3(
        x: v.x / length,
        y: v.y / length,
        z: v.z / length
    )
}

func computeNormal(v0: Vec3, v1: Vec3, v2: Vec3) -> Vec3 {
    let edge1 = v1 - v0
    let edge2 = v2 - v0
    
    let n = cross(edge1, edge2)
    
    return normalize(n)
}

func transform(_ m: Mat4, _ v: Vec3) -> Vec4 {
    let x = v.x
    let y = v.y
    let z = v.z
    var o: Vec4 = Vec4(x: 0, y: 0, z: 0, w: 0)
    o.x = x * m.m[0] + y * m.m[4] + z * m.m[8]  + m.m[12]
    o.y = x * m.m[1] + y * m.m[5] + z * m.m[9]  + m.m[13]
    o.z = x * m.m[2] + y * m.m[6] + z * m.m[10] + m.m[14]
    o.w = x * m.m[3] + y * m.m[7] + z * m.m[11] + m.m[15]

    o.x /= o.w
    o.y /= o.w
    o.z /= o.w
    return o
}

func translate(_ m: inout [Float], _ x: Float, _ y: Float, _ z: Float) {
    m[12] += m[0] * x + m[4] * y + m[8]  * z
    m[13] += m[1] * x + m[5] * y + m[9]  * z
    m[14] += m[2] * x + m[6] * y + m[10] * z
    m[15] += m[3] * x + m[7] * y + m[11] * z
}

func rotateX(_ m: inout [Float], _ theta: Float) {
    let c: Float = cos(theta)
    let s: Float = sin(theta)

    for i in 0..<4 {
        let y: Float = m[4 + i]
        let z: Float = m[8 + i]

        m[4 + i] = y * c + z * s
        m[8 + i] = -y * s + z * c
    }
}

func rotateY(_ m: inout [Float], _ theta: Float) {
    let c: Float = cos(theta)
    let s: Float = sin(theta)

    for i in 0..<4 {
        let x: Float = m[0 + i]
        let z: Float = m[8 + i]

        m[0 + i] = x * c - z * s
        m[8 + i] = x * s + z * c
    }
}

func rotateZ(_ m: inout [Float], _ theta: Float) {
    let c: Float = cos(theta)
    let s: Float = sin(theta)

    for i in 0..<4 {
        let x: Float = m[0 + i]
        let y: Float = m[4 + i]

        m[0 + i] = x * c + y * s
        m[4 + i] = -x * s + y * c
    }
}

func perspective(_ m: inout [Float], _ fov: Float, _ aspect: Float, _ zNear: Float, _ zFar: Float) {
    let f: Float = 1.0 / tan(fov * 0.5);
    let rangeInv: Float = 1.0 / (zFar - zNear);

    m[ 0] = f / aspect;
    m[ 1] = 0.0;
    m[ 2] = 0.0;
    m[ 3] = 0.0;

    m[ 4] = 0.0;
    m[ 5] = f;
    m[ 6] = 0.0;
    m[ 7] = 0.0;

    m[ 8]  = 0.0;
    m[ 9]  = 0.0;
    m[10] = (zFar + zNear) * rangeInv;
    m[11] = -1.0;

    m[12] = 0.0;
    m[13] = 0.0;
    m[14] = 2.0 * zFar * zNear * rangeInv;
    m[15] = 0.0;
}

func invertMat4(_ m: [Float]) -> Mat4 {
    var inv: Mat4 = Mat4()

    inv.m[0]  =   m[5]*m[10]*m[15] - m[5]*m[11]*m[14] - m[9]*m[6]*m[15]
              + m[9]*m[7]*m[14] + m[13]*m[6]*m[11] - m[13]*m[7]*m[10]

    inv.m[4]  =  -m[4]*m[10]*m[15] + m[4]*m[11]*m[14] + m[8]*m[6]*m[15]
              - m[8]*m[7]*m[14] - m[12]*m[6]*m[11] + m[12]*m[7]*m[10]

    inv.m[8]  =   m[4]*m[9]*m[15]  - m[4]*m[11]*m[13] - m[8]*m[5]*m[15]
              + m[8]*m[7]*m[13] + m[12]*m[5]*m[11] - m[12]*m[7]*m[9]

    inv.m[12] =  -m[4]*m[9]*m[14]  + m[4]*m[10]*m[13] + m[8]*m[5]*m[14]
              - m[8]*m[6]*m[13] - m[12]*m[5]*m[10] + m[12]*m[6]*m[9]

    inv.m[1]  =  -m[1]*m[10]*m[15] + m[1]*m[11]*m[14] + m[9]*m[2]*m[15]
              - m[9]*m[3]*m[14] - m[13]*m[2]*m[11] + m[13]*m[3]*m[10]

    inv.m[5]  =   m[0]*m[10]*m[15] - m[0]*m[11]*m[14] - m[8]*m[2]*m[15]
              + m[8]*m[3]*m[14] + m[12]*m[2]*m[11] - m[12]*m[3]*m[10]

    inv.m[9]  =  -m[0]*m[9]*m[15]  + m[0]*m[11]*m[13] + m[8]*m[1]*m[15]
              - m[8]*m[3]*m[13] - m[12]*m[1]*m[11] + m[12]*m[3]*m[9]

    inv.m[13] =   m[0]*m[9]*m[14]  - m[0]*m[10]*m[13] - m[8]*m[1]*m[14]
              + m[8]*m[2]*m[13] + m[12]*m[1]*m[10] - m[12]*m[2]*m[9]

    inv.m[2]  =   m[1]*m[6]*m[15]  - m[1]*m[7]*m[14] - m[5]*m[2]*m[15]
              + m[5]*m[3]*m[14] + m[13]*m[2]*m[7]  - m[13]*m[3]*m[6]

    inv.m[6]  =  -m[0]*m[6]*m[15]  + m[0]*m[7]*m[14] + m[4]*m[2]*m[15]
              - m[4]*m[3]*m[14] - m[12]*m[2]*m[7]  + m[12]*m[3]*m[6]

    inv.m[10] =   m[0]*m[5]*m[15]  - m[0]*m[7]*m[13] - m[4]*m[1]*m[15]
              + m[4]*m[3]*m[13] + m[12]*m[1]*m[7]  - m[12]*m[3]*m[5]

    inv.m[14] =  -m[0]*m[5]*m[14]  + m[0]*m[6]*m[13] + m[4]*m[1]*m[14]
              - m[4]*m[2]*m[13] - m[12]*m[1]*m[6]  + m[12]*m[2]*m[5]

    inv.m[3]  =  -m[1]*m[6]*m[11]  + m[1]*m[7]*m[10] + m[5]*m[2]*m[11]
              - m[5]*m[3]*m[10] - m[9]*m[2]*m[7]   + m[9]*m[3]*m[6]

    inv.m[7]  =   m[0]*m[6]*m[11]  - m[0]*m[7]*m[10] - m[4]*m[2]*m[11]
              + m[4]*m[3]*m[10] + m[8]*m[2]*m[7]   - m[8]*m[3]*m[6]

    inv.m[11] =  -m[0]*m[5]*m[11]  + m[0]*m[7]*m[9]  + m[4]*m[1]*m[11]
              - m[4]*m[3]*m[9]  - m[8]*m[1]*m[7]   + m[8]*m[3]*m[5]

    inv.m[15] =   m[0]*m[5]*m[10]  - m[0]*m[6]*m[9]  - m[4]*m[1]*m[10]
              + m[4]*m[2]*m[9]  + m[8]*m[1]*m[6]   - m[8]*m[2]*m[5]

    let det: Float = m[0]*inv.m[0] + m[1]*inv.m[4] + m[2]*inv.m[8] + m[3]*inv.m[12]

    if abs(det) < 1e-6 {
        return inv
    }

    let invDet: Float = 1.0 / det
    for i in 0..<16 {
        inv.m[i] *= invDet
    }
        
    return inv
}

func invertAndTransposeMat4(_ matrix: Mat4) -> Mat4 {
    let inv: Mat4 = invertMat4(matrix.m)
    var out: Mat4 = Mat4()

    for row in 0..<4 {
        for col in 0..<4 {
            out.m[col * 4 + row] = inv.m[row * 4 + col];
        }
    }

    return out
}

func clipSpace(_ v: Vec4, _ width: Int, _ height: Int) -> IntVec2 {
    return IntVec2(
        x: Int((v.x + 1) * 0.5 * Float(width)),
        y: Int((v.y + 1) * 0.5 * Float(height)),
    )
}

func load3dModel(_ obj: String, _ mtl: String) async -> [Triangle] {
    var out: [Triangle] = []
    
    var vertex: [Vec3] = []
    var colors: [String:Int] = [:]
    
    if let url = Bundle.main.url(forResource: mtl, withExtension: "mtl") {
        do {
            let source = try String(contentsOf: url, encoding: .utf8)
            let lines = source.components(separatedBy: .newlines)
            
            var cur: String = ""
            for line in lines {
                let words = line.split(separator: " ")
                
                if let firstWord = words.first {
                    if firstWord == "newmtl" {
                        cur = String(words[1])
                    } else if firstWord == "Kd" {
                        let r = Int(Float(words[1])! * 255)
                        let g = Int(Float(words[2])! * 255)
                        let b = Int(Float(words[3])! * 255)
                        colors[cur] = r | (g << 8) | (b << 16) | (255 << 24)
                    }
                }
            }
        } catch {
            print("Erro ao ler arquivo:", error)
        }
    }
    
    if let url = Bundle.main.url(forResource: obj, withExtension: "obj") {
        do {
            let content = try String(contentsOf: url, encoding: .utf8)
            
            var cur: String = ""
            for line in content.split(whereSeparator: \.isNewline) {
                let parts = line.split(whereSeparator: \.isWhitespace)
                
                guard let type = parts.first else { continue }
                
                switch type {
                case "v":
                    vertex.append(
                        Vec3(x: Float(parts[1])!, y: Float(parts[2])!, z: Float(parts[3])!)
                    )
                    
                case "usemtl":
                    cur = String(parts[1])
                    
                case "f":
                    let i0: Int = Int(parts[1])! - 1
                    let i1: Int = Int(parts[2])! - 1
                    let i2: Int = Int(parts[3])! - 1
                    
                    let v0 = vertex[i0]
                    let v1 = vertex[i1]
                    let v2 = vertex[i2]
                    
                    let normal = computeNormal(v0: v0, v1: v1, v2: v2)
                    out.append(
                        Triangle(
                            v0: v0, v1: v1, v2: v2,
                            normal: normal,
                            color: colors[cur]!
                        )
                    )
                    
                default:
                    break
                }
            }
        } catch {
            print("Erro ao ler .obj:", error)
        }
    }
    return out
}

func cpuRender(_ model: RenderModel, _ parallel: Bool = false) {
    model.currentTask?.cancel()
    if !model.loaded {return}
    model.currentTask = Task {
        let width = model.width
        let height = model.height
        let zNear = model.zNear
        let zFar = model.zFar
        let fov = model.fov
        let triangles = model.triangles//load3dModel(model.obj, model.mtl)
        
        
        var projection: Mat4 = Mat4()
        perspective(&projection.m, fov, Float(width) / Float(height), zNear, zFar)
        translate(&projection.m, model.x, model.y, model.z)
        rotateX(&projection.m, model.angleX)
        rotateY(&projection.m, model.angleY)
        rotateZ(&projection.m, model.angleZ)
        
        var normalMatrix: Mat4 = Mat4(identity: true)
        rotateX(&normalMatrix.m, model.angleX)
        rotateY(&normalMatrix.m, model.angleY)
        rotateZ(&normalMatrix.m, model.angleZ)
        
        normalMatrix = invertAndTransposeMat4(normalMatrix)
        
        var zBuffer: [Float] = Array(repeating: Float.infinity, count:width * height)
        var normalBuffer: [Vec3] = Array(repeating: Vec3(x: 0, y: 0, z: 0), count:width * height)
        
        var clipedTriangles: [ClipedTriangle] = []
        clipedTriangles.reserveCapacity(triangles.count)
        
        // Vertex Shader
        for t in triangles {
            let v0: Vec4 = transform(projection, t.v0)
            let v1: Vec4 = transform(projection, t.v1)
            let v2: Vec4 = transform(projection, t.v2)
            
            let v0c: IntVec2 = clipSpace(v0, width, height)
            let v1c: IntVec2 = clipSpace(v1, width, height)
            let v2c: IntVec2 = clipSpace(v2, width, height)
            
            let tNormal = transform(normalMatrix, t.normal)
            
            let area: Float = Float(cross2D(v0c, v1c, v2c))
            
            if area < 0 {continue}
            
            clipedTriangles.append(
                ClipedTriangle(
                    v0: v0c,
                    v1: v1c,
                    v2: v2c,
                    
                    normal: tNormal,
                    
                    z0: v0.w * area,
                    z1: v1.w * area,
                    z2: v2.w * area,
                    
                    color: t.color
                )
            )
        }
        
        let tileSize = parallel ? model.tileSize : max(width, height)
        let tileCols: Int = parallel ? (width + tileSize - 1) / tileSize : 1
        let tileRows: Int = parallel ? (height + tileSize - 1) / tileSize : 1
        
        let bufferLock = NSLock() // 🔒 lock para proteger os buffers
        
        await withTaskGroup(of: Void.self) { group in
            for tileY in 0..<tileRows {
                for tileX in 0..<tileCols {
                    let minXTile = tileX * tileSize
                    let minYTile = tileY * tileSize
                    let maxXTile = min((tileX + 1) * tileSize, width)
                    let maxYTile = min((tileY + 1) * tileSize, height)
                    
                    group.addTask {
                        for t in clipedTriangles {
                            let v0 = t.v0
                            let v1 = t.v1
                            let v2 = t.v2
                            let normal: Vec3 = Vec3(x: t.normal.x, y: t.normal.y, z: t.normal.z)
                            
                            let minX = max(min(v0.x, v1.x, v2.x), minXTile)
                            let minY = max(min(v0.y, v1.y, v2.y), minYTile)
                            let maxX = min(max(v0.x, v1.x, v2.x), maxXTile - 1)
                            let maxY = min(max(v0.y, v1.y, v2.y), maxYTile - 1)
                            
                            if minX > maxX || minY > maxY { continue }
                            
                            for y in minY...maxY {
                                for x in minX...maxX {
                                    if Task.isCancelled { return }
                                    let p = IntVec2(x: x, y: y)
                                    let w0 = Float(cross2D(v1, v2, p)) / t.z0
                                    let w1 = Float(cross2D(v2, v0, p)) / t.z1
                                    let w2 = Float(cross2D(v0, v1, p)) / t.z2
                                    
                                    if w0 >= 0 && w1 >= 0 && w2 >= 0 {
                                        let idx = y * width + x
                                        let depth: Float = 1 / (w0 + w1 + w2)
                                        
                                        // 🔒 Bloqueia enquanto atualiza buffers globais
                                        bufferLock.lock()
                                        if depth < zBuffer[idx] {
                                            zBuffer[idx] = depth
                                            model.frameBuffer[idx] = t.color
                                            normalBuffer[idx] = normal
                                        }
                                        bufferLock.unlock()
                                        
                                        // Simula render concorrente pixel a pixel
                                        let sleep = UInt64(1_000 * (1 - model.speed))
                                        try? await Task.sleep(nanoseconds: sleep)
                                        if Task.isCancelled { return }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
        let lightDir: Vec3 = normalize(Vec3(x: -0.5, y: -1, z: 1))
        let ambientIntensity: Float = 0.2
        let diffuseIntensity: Float = 0.8
        

        await withTaskGroup(of: Void.self) { group in
            for tileY in 0..<tileRows {
                for tileX in 0..<tileCols {
                    let minXTile = tileX * tileSize
                    let minYTile = tileY * tileSize
                    let maxXTile = min((tileX + 1) * tileSize, width)
                    let maxYTile = min((tileY + 1) * tileSize, height)
                    
                    if minXTile > maxXTile || minYTile > maxYTile { continue }
                    
                    group.addTask {
                        for y in minYTile..<maxYTile {
                            for x in minXTile..<maxXTile {
                                if Task.isCancelled { return }
                                let idx = y * width + x
                                if zBuffer[idx] == Float.infinity { continue }
                                
                                let n: Vec3 = normalize(normalBuffer[idx])
                                let NdotL: Float = max(n.x * lightDir.x + n.y * lightDir.y + n.z * lightDir.z, 0)
                                let intensity: Float = min(ambientIntensity + diffuseIntensity * NdotL, 1)
                                
                                bufferLock.lock()
                                let color: Int = model.frameBuffer[idx]
                                var r: Int = color & 0xff
                                var g: Int = (color >> 8) & 0xff
                                var b: Int = (color >> 16) & 0xff
                                var a: Int = (color >> 24) & 0xff
                                
                                r = min(Int(Float(r) * intensity), 255)
                                g = min(Int(Float(g) * intensity), 255)
                                b = min(Int(Float(b) * intensity), 255)
                                a = min(Int(Float(a) * intensity), 255)
                                
                                // 🔒 lock ao escrever no framebuffer
                                model.frameBuffer[idx] = r | (g << 8) | (b << 16) | (a << 24)
                                bufferLock.unlock()
                                
                                // simula render concorrente pixel a pixel
                                let sleep = UInt64(100_000 * (1 - model.speed))
                                try? await Task.sleep(nanoseconds: sleep)
                                if Task.isCancelled { return }
                            }
                        }
                    }
                }
            }
        }
    }
}
