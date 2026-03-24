func hillClimbingParallel(_ model: TSalesmanModel){
    model.currentTask?.cancel()
    model.currentTask = Task {
        let initialStates = 2000
        var bestCost = TSalesmanModel.computeCost(model.points)
        let n = model.points.count
        
        let originalPoints = model.points
        
        for _ in 0..<initialStates {
            var pointsCopy = originalPoints
            pointsCopy[1...].shuffle()
            var actualCost = TSalesmanModel.computeCost(pointsCopy)
            while true {
                if Task.isCancelled {return}
                var minCost = actualCost
                var s = -1
                var e = -1
                for i in 1..<n-1 {
                    for j in i+1..<n {
                        if Task.isCancelled {return}
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
                if minCost == actualCost {break}
                actualCost = minCost
                pointsCopy.swapAt(s, e)
                
                if actualCost < bestCost {
                    bestCost = actualCost
                    model.points = pointsCopy
                    model.totalCost = bestCost
                    
                    let sleep = UInt64(10_000_000 * (1 - model.speed))
                    try? await Task.sleep(nanoseconds: sleep)
                    if Task.isCancelled {return}
                }
            }
        }
    }
}
