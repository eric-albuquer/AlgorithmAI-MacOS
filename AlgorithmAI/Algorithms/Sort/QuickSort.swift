func quickSort(_ model: SortModel){
    model.currentTask?.cancel()
    model.currentTask = Task {
        var stack: [(start: Int, end: Int)] = [(start: 0, end: model.array.count - 1)]
        
        while stack.count > 0 {
            let (start, end) = stack.removeLast()
            
            if start >= end {continue}
            
            let pIdx = Int.random(in: start...end)
            model.array.swapAt(end, pIdx)
            let pivot = model.array[end]
            var idx = start
            
            for i in start..<end {
                if model.array[i] < pivot {
                    model.array.swapAt(i, idx)
                    idx += 1
                    
                    let sleep = UInt64(100_000_000 * (1 - model.speed))
                    try? await Task.sleep(nanoseconds: sleep)
                    if Task.isCancelled {return}
                }
            }
            
            model.array.swapAt(idx, end)
            
            let sleep = UInt64(100_000_000 * (1 - model.speed))
            try? await Task.sleep(nanoseconds: sleep)
            if Task.isCancelled {return}
            
            stack.append((start: start, end: idx - 1))
            stack.append((start: idx + 1, end: end))
        }
    }
}
