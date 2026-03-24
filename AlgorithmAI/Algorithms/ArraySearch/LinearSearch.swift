func linearSearch(_ model: ArraySearchModel){
    model.currentTask?.cancel()
    model.currentTask = Task {
        let n = model.array.count
        for i in 0..<n {
            await MainActor.run {
                model.minIdx = i - 1
                model.maxIdx = i + 1
                model.midIdx = i
            }
            
            if model.array[i] == model.element {return}
        
            let sleep = UInt64(100_000_000 * (1 - model.speed))
            try? await Task.sleep(nanoseconds: sleep)
            if Task.isCancelled { return }
        }
    }
}
