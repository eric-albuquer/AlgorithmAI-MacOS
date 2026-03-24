func nextPermutation(_ arr: inout [Int]) -> Bool {
    let n = arr.count
    
    var i = n - 2
    while i >= 0 && arr[i] >= arr[i + 1] {i -= 1}
    
    if i < 0 {
        arr.reverse()
        return false
    }
    
    var j = n - 1
    while arr[j] <= arr[i] {j -= 1}
    
    arr.swapAt(i, j)
    arr[(i + 1)...].reverse()
    
    return true
}

func bruteForce(_ model: TSalesmanModel){
    model.currentTask?.cancel()
    model.currentTask = Task {
        let n = model.points.count
        let aux = model.points
        var idxArr: [Int] = Array(1..<n)
        var bestCost = TSalesmanModel.computeCost(model.points)
        var bestArr = idxArr
        repeat {
            for i in 0..<n-1 {
                model.points[i + 1] = aux[idxArr[i]]
            }
            let cost = TSalesmanModel.computeCost(model.points)
            if cost < bestCost {
                bestCost = cost
                bestArr = idxArr
            }
            
            model.totalCost = cost
            let sleep = UInt64(100_000_000 * (1 - model.speed))
            try? await Task.sleep(nanoseconds: sleep)
            if Task.isCancelled {return}
        } while nextPermutation(&idxArr)
        
        for i in 0..<n-1 {
            model.points[i + 1] = aux[bestArr[i]]
        }
        model.totalCost = TSalesmanModel.computeCost(model.points)
    }
}
