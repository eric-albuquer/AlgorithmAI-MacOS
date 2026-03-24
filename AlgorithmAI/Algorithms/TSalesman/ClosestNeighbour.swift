import Darwin

func dist(_ a: Point, _ b: Point) -> Double {
    return hypot(a.x - b.x, a.y - b.y)
}

func closestNeighbour(_ model: TSalesmanModel){
    model.currentTask?.cancel()
    model.currentTask = Task {
        let n = model.points.count
        for i in 0..<n-1 {
            let pi = model.points[i]
            var closestIdx: Int = -1
            var minDist: Double = 1
            for j in i+1..<n {
                let pj = model.points[j]
                let d = dist(pi, pj)
                if d < minDist {
                    minDist = d
                    closestIdx = j
                }
            }
            let sleep = UInt64(1_000_000_000 * (1 - model.speed))
            try? await Task.sleep(nanoseconds: sleep)
            if Task.isCancelled {return}
            model.points.swapAt(i + 1, closestIdx)
            model.totalCost = TSalesmanModel.computeCost(model.points)
        }
    }
}
