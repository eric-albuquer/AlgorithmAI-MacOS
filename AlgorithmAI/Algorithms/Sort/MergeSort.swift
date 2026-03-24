func mergeSort(_ model: SortModel){
    model.currentTask?.cancel()
    model.currentTask = Task {
        let n = model.array.count
        var aux = model.array
        
        var size = 1
        
        while size < n {
            let nextSize = size << 1
            var idx = 0
            while idx < n {
                let start = idx
                let mid = min(start + size, n)
                let end = min(start + nextSize, n)
                
                var i = idx
                var j = mid
                var k = idx
                
                while i < mid && j < end {
                    if aux[i] < aux[j] {
                        model.array[k] = aux[i]
                        i += 1
                    } else {
                        model.array[k] = aux[j]
                        j += 1
                    }
                    k += 1
                    
                    let sleep = UInt64(100_000_000 * (1 - model.speed))
                    try? await Task.sleep(nanoseconds: sleep)
                    if Task.isCancelled {return}
                }
                
                while i < mid {
                    model.array[k] = aux[i]
                    i += 1
                    k += 1
                    
                    let sleep = UInt64(100_000_000 * (1 - model.speed))
                    try? await Task.sleep(nanoseconds: sleep)
                    if Task.isCancelled {return}
                }
                
                while j < end {
                    model.array[k] = aux[j]
                    j += 1
                    k += 1
                    
                    let sleep = UInt64(100_000_000 * (1 - model.speed))
                    try? await Task.sleep(nanoseconds: sleep)
                    if Task.isCancelled {return}
                }
                idx += nextSize
            }
            aux = model.array
            size = nextSize
        }
    }
}
