func discardStates(_ model: AutomatonModel){
    model.currentTask?.cancel()
    model.currentTask = Task {
        let nodes = model.nodes
        let start = model.start
        let states = model.states
        
        var visited: Set<String> = []

        func dfs(_ cur: String){
            if visited.contains(cur) {return}
            visited.insert(cur)
            guard let adj = nodes[cur] else {return}
            for (_, others) in adj {
                for other in others {
                    if other == cur {continue}
                    dfs(other)
                }
            }
        }

        dfs(start)

        for state in states {
            if visited.contains(state) {continue}
            
            let sleep = UInt64(10_000_000 * (1 - model.speed))
            try? await Task.sleep(nanoseconds: sleep)
            if Task.isCancelled { return }
            
            await MainActor.run {
                model.states.remove(state)
                model.end.remove(state)
                model.nodes.removeValue(forKey: state)
            }
        }
    }
}
