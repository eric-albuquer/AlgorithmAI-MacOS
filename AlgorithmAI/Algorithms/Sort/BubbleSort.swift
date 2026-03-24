func bubbleSort(_ model: SortModel){
    model.currentTask?.cancel()
    model.currentTask = Task {
        let n = model.array.count
        for i in 0..<n {
            for j in 0..<n-i-1 {
                if model.array[j] > model.array[j + 1] {
                    await MainActor.run {
                        model.array.swapAt(j + 1, j)
                    }
                }
                
                let sleep = UInt64(100_000_000 * (1 - model.speed))
                try? await Task.sleep(nanoseconds: sleep)
                if Task.isCancelled { return }
            }
        }
    }
}
