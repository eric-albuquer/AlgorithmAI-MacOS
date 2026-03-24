func bruteForceSort(_ model: SortModel){
    model.currentTask?.cancel()
    model.currentTask = Task {
        let origin = model.array
        let n = model.array.count
        var visited: [Bool] = Array(repeating: false, count: n)
        var arr: [Int] = []
        
        func isSorted() -> Bool {
            for i in 1..<n {
                if arr[i] < arr[i - 1] {return false}
            }
            
            return true
        }
        
        func dfs() async -> Bool {
            if arr.count == n {
                let copy = arr
                await MainActor.run {
                    model.array = copy
                }
                
                if isSorted() {return true}
                
                let sleep = UInt64(10_000_000 * (1 - model.speed))
                try? await Task.sleep(nanoseconds: sleep)
                if Task.isCancelled { return true }
                
                return false
            }
            
            for i in 0..<n {
                if !visited[i] {
                    arr.append(origin[i])
                    visited[i] = true
                    if await dfs() {return true}
                    arr.removeLast()
                    visited[i] = false
                }
            }
            
            return false
        }
        
        _ = await dfs()
    }
}
