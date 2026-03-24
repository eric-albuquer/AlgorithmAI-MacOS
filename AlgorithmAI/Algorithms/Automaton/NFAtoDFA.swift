func nfaToDfa(_ model: AutomatonModel) -> Void {
    model.currentTask?.cancel()
    model.currentTask = Task {
        let modelNodes = model.nodes
        let modelEnd = model.end
        let modelStart = model.start
        let modelStates = model.states
        
        let keys = Array(modelStates).sorted()
        let n = keys.count
        var nodes: [String:[String:[String]]] = [:]
        var ends: Set<String> = []

        // backtraking de nodes (permutação)
        func nodesDfs(_ arr: inout [String], _ s: Int) async {
            let str = arr.joined(separator: ",") // chave combinada de estados
            nodes[str] = [:]

            let qSet: Set<String> = Set(arr)
            if !qSet.isDisjoint(with: modelEnd) { // buscando intersecção do no com o conjunto final
                ends.insert(str) // adicionar chave ao novo conjunto de fim
            }

            for letter in model.alphabet {
                var qs: Set<String> = [] // novas conexões para aquele nó
                for q in arr {
                    guard let adj: [String:[String]] = modelNodes[q] else {continue}
                    guard let connections: [String] = adj[letter] else {continue}
                    qs.formUnion(connections) // adicionando nós vizinhos para construir a chave
                    for c in connections {
                        guard let adjE: [String:[String]] = modelNodes[c] else {continue} // buscando epsilon para adicionar estado vizinho
                        if let t: [String] = adjE[""] {
                            qs.formUnion(t)
                        }
                    }
                }
                let setString: String = Array(qs).sorted().joined(separator: ",") // construindo chave
                nodes[str]![letter] = [setString]
                
                let sleep = UInt64(1_000_000 * (1 - model.speed))
                try? await Task.sleep(nanoseconds: sleep)
                if Task.isCancelled { return }
                
                let nodesCopy = nodes
                let endsCopy = ends
                await MainActor.run {
                    model.nodes = nodesCopy
                    model.end = endsCopy
                    model.states = Set(nodesCopy.keys)
                }
            }

            for i in s..<n { // backtraking
                arr.append(keys[i])
                await nodesDfs(&arr, i + 1)
                arr.removeLast()
            }
        }
        var buffer: [String] = []
        await nodesDfs(&buffer, 0)

        var start: Set<String> = []

        // construindo inicio com backtraking de epsilon
        func startDfs(_ cur: String){
            if start.contains(cur) {return}
            start.insert(cur)

            guard let adj: [String:[String]] = modelNodes[cur] else {return}
            guard let connections: [String] = adj[""] else {return}

            // backtraking
            for c in connections {
                startDfs(c)
            }
        }

        startDfs(modelStart)
        
        let sleep = UInt64(1_000_000_000 * (1 - model.speed))
        try? await Task.sleep(nanoseconds: sleep)
        if Task.isCancelled { return }
        
        let startCopy = start
        await MainActor.run {
            model.start = Array(startCopy).sorted().joined(separator: ",")
        }
            
//        return DFA(
//            alphabet: Array(model.alphabet),
//            states: Array(nodes.keys),
//            start: Array(start).sorted().joined(separator: ","),
//            end: Array(ends),
//            nodes: nodes
//        )
    }
}
