func quickSelect(_ model: ArraySearchModel){
    model.currentTask?.cancel()
    model.currentTask = Task {
        var left = 0
        var right = model.array.count - 1
        
        while left <= right {
            let l = left
            let r = right
            
            let pivot = model.array[right]
            var idx = l
            
            for i in l..<r {
                if model.array[i] < pivot {
                    model.array.swapAt(i, idx)
                    idx += 1
                    
                    let sleep = UInt64(1_000_000_000 * (1 - model.speed))
                    try? await Task.sleep(nanoseconds: sleep)
                    if Task.isCancelled { return }
                }
            }
            
            model.array.swapAt(idx, right)
            
            await MainActor.run {
                model.minIdx = l
                model.maxIdx = r
                model.midIdx = idx
            }
            
            let e = model.array[idx]
            if e == model.element {return}
            if e < model.element {
                left = idx + 1
            } else {
                right = idx - 1
            }
        }
    }
}
