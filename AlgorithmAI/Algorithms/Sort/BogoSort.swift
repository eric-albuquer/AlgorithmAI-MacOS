func bogoSort(_ model: SortModel){
    model.currentTask?.cancel()
    model.currentTask = Task {
        let n = model.array.count
        var arr = model.array
        
        func isSorted() -> Bool {
            for i in 1..<n {
                if arr[i] < arr[i - 1] {return false}
            }
            
            return true
        }
    
        repeat {
            let sleep = UInt64(10_000_000 * (1 - model.speed))
            try? await Task.sleep(nanoseconds: sleep)
            if Task.isCancelled { return }
            
            arr.shuffle()
            let copy = arr
            await MainActor.run {
                model.array = copy
            }
        } while !isSorted()
    }
}
