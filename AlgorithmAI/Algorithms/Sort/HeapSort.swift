func heapSort(_ model: SortModel){
    model.currentTask?.cancel()
    model.currentTask = Task {
        let n = model.array.count
        func heapfy(_ idx: Int, _ n: Int) async {
            var i = idx
            while true {
                let l = (i << 1) | 1
                let r = l + 1
                
                var m = i
                
                if l < n && model.array[l] > model.array[m] {m = l}
                if r < n && model.array[r] > model.array[m] {m = r}
                
                if m == i {break}
                
                let s = i
                let e = m
                
                let sleep = UInt64(100_000_000 * (1 - model.speed))
                try? await Task.sleep(nanoseconds: sleep)
                if Task.isCancelled { return }
                
                await MainActor.run {
                    model.array.swapAt(s, e)
                }
                i = m
            }
        }
        
        var i = (n >> 1) - 1
        while i >= 0 {
            await heapfy(i, n)
            i -= 1
        }
        
        i = n - 1
        while i >= 1 {
            let idx = i
            let sleep = UInt64(100_000_000 * (1 - model.speed))
            try? await Task.sleep(nanoseconds: sleep)
            if Task.isCancelled { return }
            
            await MainActor.run {
                model.array.swapAt(0, idx)
            }
            await heapfy(0, i)
            i -= 1
        }
    }
}
