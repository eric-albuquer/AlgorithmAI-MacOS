func dfa(_ model: AutomatonModel){
    model.currentTask?.cancel()
    model.reset()
    model.currentTask = Task {
        for l in model.entry {
            guard let adj = model.nodes[model.cur] else {return}
            guard let others = adj[String(l)] else {return}
            
            let sleep = UInt64(1_000_000_000 * (1 - model.speed))
            try? await Task.sleep(nanoseconds: sleep)
            if Task.isCancelled { return }
            
            await MainActor.run {
                model.cur = others[0]
                model.idx += 1
            }
        }
    }
}
