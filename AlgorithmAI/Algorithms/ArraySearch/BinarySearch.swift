func binarySearch(_ model: ArraySearchModel){
    model.currentTask?.cancel()
    model.currentTask = Task {
        var left = 0
        var right = model.array.count - 1
        
        while left <= right {
            let l = left
            let r = right
            
            let mid = (l + r) / 2
            
            await MainActor.run {
                model.minIdx = l
                model.maxIdx = r
                model.midIdx = mid
            }
            
            let e = model.array[mid]
            if e == model.element {return}
            if e < model.element {
                left = mid + 1
            } else {
                right = mid - 1
            }
        
            let sleep = UInt64(1_000_000_000 * (1 - model.speed))
            try? await Task.sleep(nanoseconds: sleep)
            if Task.isCancelled { return }
        }
    }
}
