func nfa(_ model: AutomatonModel){
    model.currentTask?.cancel()
    model.currentTask = Task {
        let arr = Array(model.entry)
        let n = arr.count
        
        var visited = Set<String>()
        func tree(_ cur: String, _ i: Int) async throws -> Bool {
            try Task.checkCancellation()
            let sleep = UInt64(1_000_000_000 * (1 - model.speed))
            try? await Task.sleep(nanoseconds: sleep)
            
            let key = "\(cur),\(i)"
            if visited.contains(key) { return false }
            visited.insert(key)
            
            await MainActor.run {
                model.cur = cur
                model.idx = i
            }
            if i == n {return model.end.contains(cur)}
            
            guard let adj = model.nodes[cur] else {return false}
            if let others = adj[String(arr[i])] {
                for q in others {
                    if try await tree(q, i + 1) {return true}
                }
            }
        
            guard let epsilon = adj[""] else {return false}
            
            for q in epsilon {
                if try await tree(q, i) {return true}
            }
            
            return false
        }
        
        do {
            let res = try await tree(model.start, 0)
            if !res {model.cur = ""}
        } catch {
            // cancelado → sai silenciosamente
        }
    }
}
