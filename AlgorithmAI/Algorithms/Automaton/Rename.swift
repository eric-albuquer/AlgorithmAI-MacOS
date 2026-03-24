func renameAutomaton(_ model: AutomatonModel){
    model.currentTask?.cancel()
    model.currentTask = Task {
        let states = model.states
        let nodes = model.nodes
        let end = model.end
        
        var id = 1
        var rename: [String:String] = [:]

        var newStates: Set<String> = []

        for key in states {
            let newKey = "q\(id)"
            rename[key] = newKey
            newStates.insert(newKey)
            id += 1
        }

        let keys = nodes.keys

        var newNodes: [String:[String:[String]]] = [:]
        for key in keys {
            let renamedKey = rename[key]!

            let transitions: [String:[String]] = nodes[key]!
            var newTransitions: [String:[String]] = [:]

            for (chr, states) in transitions {
                var newStates: [String] = []
                for s in states {
                    newStates.append(rename[s]!)
                }
                newTransitions[chr] = newStates
            }

            newNodes[renamedKey] = newTransitions
            
            let sleep = UInt64(1_000_000_000 * (1 - model.speed))
            try? await Task.sleep(nanoseconds: sleep)
            if Task.isCancelled { return }
            
            let newNodesCopy = newNodes
            await MainActor.run {
                model.nodes = newNodesCopy
            }
        }

        var newEnd: Set<String> = []

        for key in end {
            newEnd.insert(rename[key]!)
            
            let sleep = UInt64(10_000_000_000 * (1 - model.speed))
            try? await Task.sleep(nanoseconds: sleep)
            if Task.isCancelled { return }
            
            let newEndCopy = newEnd
            await MainActor.run {
                model.end = newEndCopy
            }
        }

        let renameCopy = rename
        let newStatesCopy = newStates
        await MainActor.run {
            model.start = renameCopy[model.start]!
            model.states = newStatesCopy
        }
    }
}
