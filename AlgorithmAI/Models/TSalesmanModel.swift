import Foundation
import Darwin

struct Point {
    let x: Double
    let y: Double
    init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }
}

@Observable
class TSalesmanModel: AlgorithmModel {
    var points: [Point] = []
    var totalCost: Double = 0
    
    init(_ count: Int){
        super.init()
        for _ in 0..<count {
            points.append(Point(x: Double.random(in: 0.05...0.95),y: Double.random(in: 0.05...0.95)))
        }
        
        totalCost = 0
        for i in 1..<count {
            let p = points[i]
            let l = points[i - 1]
            totalCost += hypot(p.x - l.x, p.y - l.y)
        }
    }
    
    static func computeCost(_ points: [Point]) -> Double {
        let count = points.count
        var totalCost: Double = 0
        for i in 1..<count {
            let p = points[i]
            let l = points[i - 1]
            totalCost += hypot(p.x - l.x, p.y - l.y)
        }
        
        return totalCost
    }
    
    func shuffle() {
        currentTask?.cancel()
        points[1...].shuffle()
        totalCost = TSalesmanModel.computeCost(points)
    }
    
    func reset(){
        currentTask?.cancel()
        let count = points.count
        points = []
        for _ in 0..<count {
            points.append(Point(x: Double.random(in: 0.05...0.95),y: Double.random(in: 0.05...0.95)))
        }
        totalCost = TSalesmanModel.computeCost(points)
    }
}
