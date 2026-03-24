import Darwin
import Foundation

@Observable
class LinearSolverModel: AlgorithmModel {
    var a = Double.random(in: -1...1)
    var b = Double.random(in: -1...1)
    
    var ta = Double.random(in: -1...1)
    var tb = Double.random(in: -1...1)
    
    func reset() {
        currentTask?.cancel()
        a = Double.random(in: -1...1)
        b = Double.random(in: -1...1)
        
        ta = Double.random(in: -1...1)
        tb = Double.random(in: -1...1)
    }
    
    static func dist(_ a: Double, _ ta: Double, _ b: Double, _ tb: Double) -> Double {
        return hypot(a - ta, b - tb)
    }
}
