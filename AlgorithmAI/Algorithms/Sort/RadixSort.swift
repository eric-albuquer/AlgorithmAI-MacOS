func radixSort(_ model: SortModel){
    model.currentTask?.cancel()
    model.currentTask = Task {
        let n = model.array.count
        let bits = 8
        let totalBuckets = 1 << bits
        let mask = totalBuckets - 1
        
        var buckets = Array(repeating: 0, count: totalBuckets)
        var aux = Array(repeating: 0, count: n)
        
        var b = 0
        while b < 16 {
            if Task.isCancelled {return}
            aux = await MainActor.run {
                model.array
            }
            // Clear buckets
            for i in 0..<totalBuckets {buckets[i] = 0}
            // Counting
            for i in 0..<n {
                buckets[(aux[i] >> b) & mask] += 1
            }
            //Prefix Sum
            for i in 1..<totalBuckets {
                buckets[i] += buckets[i - 1]
            }
            
            for i in stride(from: n - 1, through: 0, by: -1) {
                let e = aux[i]
                let bIdx = (e >> b) & mask
                buckets[bIdx] -= 1
                let idx = buckets[bIdx]
                await MainActor.run {
                    model.array[idx] = e
                }
                
                let sleep = UInt64(100_000_000 * (1 - model.speed))
                try? await Task.sleep(nanoseconds: sleep)
                if Task.isCancelled {return}
            }
            b += bits
        }
    }
}
