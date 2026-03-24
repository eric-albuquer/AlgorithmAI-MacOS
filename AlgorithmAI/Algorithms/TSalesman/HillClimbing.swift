func hillClimbing(_ model: TSalesmanModel){
    model.currentTask?.cancel()
    model.currentTask = Task {
        var bestCost = TSalesmanModel.computeCost(model.points)
        let n = model.points.count
        var pointsCopy = model.points
        while true {
            var minCost = bestCost
            var s = -1
            var e = -1
            for i in 1..<n-1 {
                for j in i+1..<n {
                    pointsCopy.swapAt(i, j)
                    let cost = TSalesmanModel.computeCost(pointsCopy)
                    pointsCopy.swapAt(i, j)
                    if cost < minCost {
                        minCost = cost
                        s = i
                        e = j
                    }
                }
            }
            if minCost == bestCost {break}
            bestCost = minCost
            pointsCopy.swapAt(s, e)
            model.points = pointsCopy
            model.totalCost = bestCost
            
            let sleep = UInt64(100_000_000 * (1 - model.speed))
            try? await Task.sleep(nanoseconds: sleep)
            if Task.isCancelled {return}
        }
    }
}
