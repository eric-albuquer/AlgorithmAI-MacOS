struct DFA: CustomStringConvertible {
    var alphabet: Set<String>
    var states: Set<String>
    var start: String
    var end: Set<String>
    var nodes: [String:[String:String]]

    init(alphabet: [String], states: [String], start: String, end: [String], nodes: [String:[String:String]]) {
        self.alphabet = Set(alphabet)
        self.states = Set(states)
        self.start = start
        self.end = Set(end)
        self.nodes = nodes
    }

    // ============================================================
    // TESTAR STRING EM DFA
    // ============================================================

    func check(_ word: String) -> Bool {
        var cur: String = start
        for l in word {
            guard let next = nodes[cur]?[String(l)] else { return false }
            cur = next
        }
        return end.contains(cur)
    }

    // ============================================================
    // RENOMEAR DFA
    // ============================================================

    mutating func rename() {
        var id = 1
        var rename: [String:String] = [:]

        var newStates: Set<String> = []

        for key in states {
            let newKey = "q\(id)"
            rename[key] = newKey
            newStates.insert(newKey)
            id += 1
        }

        let keys = self.nodes.keys

        var newNodes: [String:[String:String]] = [:]
        for key in keys {
            let renamedKey = rename[key]!

            let transitions: [String:String] = self.nodes[key]!
            var newTransitions: [String:String] = [:]

            for (chr, state) in transitions {
                newTransitions[chr] = rename[state]
            }

            newNodes[renamedKey] = newTransitions
        }

        var newEnd: Set<String> = []

        for key in self.end {
            newEnd.insert(rename[key]!)
        }

        self.start = rename[self.start]!
        self.end = newEnd
        self.states = newStates
        self.nodes = newNodes
    }

    // ============================================================
    // DESCARTAR ESTADOS NÃO USADOS
    // ============================================================

    mutating func discartUnusedStates() {
        var visited: Set<String> = []

        func dfs(_ cur: String){
            if visited.contains(cur) {return}
            visited.insert(cur)
            let adj = nodes[cur]!
            for (_, other) in adj {
                if other == cur {continue}
                dfs(other)
            }
        }

        dfs(start)

        for state in states {
            if visited.contains(state) {continue}
            states.remove(state)
            end.remove(state)
            nodes.removeValue(forKey: state)
        }
    }

    // ============================================================
    // TO STRING
    // ============================================================

    var description: String {
        func format(_ value: String) -> String {
            return value.isEmpty ? "ε" : value
        }
        let nodesDescription = nodes
            .sorted { $0.key < $1.key }
            .map { (state, transitions) -> String in
                let formattedTransitions = transitions
                    .sorted { $0.key < $1.key }
                    .map { symbol, target in
                        "  \(symbol) → \(format(target))"
                    }
                    .joined(separator: "\n")

                return """
                \(format(state)):
                \(formattedTransitions)
                """
            }
            .joined(separator: "\n")

        return """
        States: \(states.sorted()))
        Alphabet: \(alphabet.sorted())
        Start: \(start)
        End: \(end.sorted())

        Nodes:
        \(nodesDescription)
        """
    }
}

struct NFA : CustomStringConvertible{
    var alphabet: Set<String>
    var states: Set<String>
    var start: String
    var end: Set<String>
    var nodes: [String:[String:[String]]]

    init(alphabet: [String], states: [String], start: String, end: [String], nodes: [String:[String:[String]]]) {
        self.alphabet = Set(alphabet)
        self.states = Set(states)
        self.start = start
        self.end = Set(end)
        self.nodes = nodes
    }

    // ============================================================
    // TESTAR STRING EM NFA
    // ============================================================

    func check(_ s: String) -> (result: Bool, branches: Int) {
        let arr: [Character] = Array(s)
        let N: Int = arr.count

        struct State: Hashable{
            let cur: String
            let i: Int
        }

        var branches: Int = 0
        var visited: Set<State> = []

        var stack: [State] = [State(cur: self.start, i: 0)]

        while !stack.isEmpty {
            let state = stack.removeLast()

            if visited.contains(state) { continue }
            visited.insert(state)

            let cur = state.cur
            let i = state.i

            branches += 1

            if i == N {
                if end.contains(cur) {
                    return (true, branches)
                }
                continue
            }

            guard let adj = nodes[cur] else { continue }

            let c = String(arr[i])

            if let next = adj[c] {
                for q in next {
                    stack.append(State(cur: q, i: i + 1))
                }
            }

            if let next = adj[""] {
                for q in next {
                    stack.append(State(cur: q, i: i))
                }
            }
        }

        return (false, branches)
    }

    // ============================================================
    // RENOMEAR NFA
    // ============================================================

    mutating func rename() {
        var id = 1
        var rename: [String:String] = [:]

        var newStates: Set<String> = []

        for key in states {
            let newKey = "q\(id)"
            rename[key] = newKey
            newStates.insert(newKey)
            id += 1
        }

        let keys = self.nodes.keys

        var newNodes: [String:[String:[String]]] = [:]
        for key in keys {
            let renamedKey = rename[key]!

            let transitions: [String:[String]] = self.nodes[key]!
            var newTransitions: [String:[String]] = [:]

            for (chr, states) in transitions {
                var newStates: [String] = []
                for s in states {
                    newStates.append(rename[s]!)
                }
                newTransitions[chr] = newStates
            }

            newNodes[renamedKey] = newTransitions
        }

        var newEnd: Set<String> = []

        for key in self.end {
            newEnd.insert(rename[key]!)
        }

        self.start = rename[self.start]!
        self.end = newEnd
        self.states = newStates
        self.nodes = newNodes
    }

    // ============================================================
    // GERAR VERSÃO DFA
    // ============================================================

    func toDfa() -> DFA {
        let keys = Array(self.nodes.keys).sorted()
        let n = keys.count
        var nodes: [String:[String:String]] = [:]
        var ends: Set<String> = []

        // backtraking de nodes (permutação)
        func nodesDfs(_ arr: inout [String], _ s: Int){
            let str = arr.joined(separator: ",") // chave combinada de estados
            nodes[str] = [:]

            let qSet: Set<String> = Set(arr)
            if !qSet.isDisjoint(with: self.end) { // buscando intersecção do no com o conjunto final
                ends.insert(str) // adicionar chave ao novo conjunto de fim
            }

            for letter in self.alphabet {
                var qs: Set<String> = [] // novas conexões para aquele nó
                for q in arr {
                    let adj: [String:[String]] = self.nodes[q]!
                    guard let connections: [String] = adj[letter] else {continue}
                    qs.formUnion(connections) // adicionando nós vizinhos para construir a chave
                    for c in connections {
                        let adjE: [String:[String]] = self.nodes[c]! // buscando epsilon para adicionar estado vizinho
                        if let t: [String] = adjE[""] {
                            qs.formUnion(t)
                        }
                    }
                }
                let setString: String = Array(qs).sorted().joined(separator: ",") // construindo chave
                nodes[str]![letter] = setString
            }

            for i in s..<n { // backtraking
                arr.append(keys[i])
                nodesDfs(&arr, i + 1)
                arr.removeLast()
            }
        }
        var buffer: [String] = []
        nodesDfs(&buffer, 0)

        var start: Set<String> = []

        // construindo inicio com backtraking de epsilon
        func startDfs(_ cur: String){
            if start.contains(cur) {return}
            start.insert(cur)

            let adj: [String:[String]] = self.nodes[cur]!
            guard let connections: [String] = adj[""] else {return}

            // backtraking
            for c in connections {
                startDfs(c)
            }
        }

        startDfs(self.start)

        return DFA(
            alphabet: Array(self.alphabet),
            states: Array(nodes.keys),
            start: Array(start).sorted().joined(separator: ","),
            end: Array(ends),
            nodes: nodes
        )
    }

    // ============================================================
    // DESCARTAR ESTADOS NÃO USADOS
    // ============================================================

    mutating func discartUnusedStates() {
        var visited: Set<String> = []

        func dfs(_ cur: String){
            if visited.contains(cur) {return}
            visited.insert(cur)
            let adj = nodes[cur]!
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
            states.remove(state)
            end.remove(state)
            nodes.removeValue(forKey: state)
        }
    }
    
    static func fromRegex(alphabet: [String], regex: String) -> NFA {
        func addConcat(_ regex: String) -> [String] {
            let tokens = regex.map { String($0) }
            var result: [String] = []
            
            for i in 0..<tokens.count {
                let t1 = tokens[i]
                result.append(t1)
                
                if i + 1 < tokens.count {
                    let t2 = tokens[i + 1]
                    
                    let t1Ends = !["|", "("].contains(t1)
                    
                    let t2Starts = !["|", ")", "*", "+", "?"].contains(t2)
                    
                    if t1Ends && t2Starts {
                        result.append(".")
                    }
                }
            }
            
            return result
        }

        class Node {
            var next: Node? = nil
            var prev: Node? = nil
            var val: String
            var nfa: NFA? = nil

            init(_ prev: Node?, _ next: Node?, _ val: String){
                self.prev = prev
                self.next = next
                self.val = val
            }
        }
        
        struct Stack {
            var head: Node = Node(nil, nil, "")
            var top: Node

            init(){
                top = head
            }

            func isEmpty() -> Bool {
                return top === head
            }

            mutating func push(_ s: String) {
                top.next = Node(top, nil, s)
                top = top.next!
            }

            func peek() -> String {
                return top.val
            }

            mutating func pop() -> String {
                let val = top.val
                top = top.prev!
                top.next = nil
                return val
            }
        }

        let precedence: [String:Int] = [
            "*": 3,
            "+": 3,
            "?": 3,
            ".": 2,
            "|": 1
        ]

        var opStack: [String] = []
        var output = Stack()

        let tokens = addConcat(regex)

        for token in tokens {
            if token == "(" {
                opStack.append(token)
            } else if token == ")" {
                while opStack.count > 0 {
                    let p = opStack.removeLast()
                    if p == "(" {break}
                    output.push(p)
                }
            } else {
                guard let v = precedence[token] else {
                    output.push(token)
                    continue
                }
                while opStack.count > 0 {
                    let op = opStack.last!
                    if op == "(" {break}
                    if v > precedence[op]! {break}
                    opStack.removeLast()
                    output.push(op)
                }
                opStack.append(token)
            }
        }

        while opStack.count > 0 {
            output.push(opStack.removeLast())
        }

        var stateCounter: Int = 0

        func getId() -> String {
            let id = "q\(stateCounter)"
            stateCounter += 1
            return id
        }

        func buildNFALetter(_ letter: String) -> NFA {
            let q0 = getId()
            let q1 = getId()
            
            return NFA(
                alphabet: alphabet,
                states: [q0, q1],
                start: q0,
                end: [q1],
                nodes: [
                    q0: [
                        letter: [q1]
                    ]
                ]
            )
        }

        func buildNFAConcat(_ a: NFA, _ b: NFA) -> NFA {
            var nodes: [String:[String:[String]]] = [:]

            for (key, value) in a.nodes {
                nodes[key] = value
            }

            for (key, value) in b.nodes {
                nodes[key] = value
            }
 
            for state in a.end {
                nodes[state, default: [:]]["", default: []].append(b.start)
            }

            return NFA(
                alphabet: alphabet,
                states: Array(a.states.union(b.states)),
                start: a.start,
                end: Array(b.end),
                nodes: nodes
            )
        }

        func buildNFAUnion(_ a: NFA, _ b: NFA) -> NFA {
            var nodes: [String:[String:[String]]] = [:]

            for (key, value) in a.nodes {
                nodes[key] = value
            }

            for (key, value) in b.nodes {
                nodes[key] = value
            }
 
            let q0 = getId()
            nodes[q0] = [
                "": [
                    a.start,
                    b.start
                ]
            ]

            return NFA(
                alphabet: alphabet,
                states: Array(a.states.union(b.states)) + [q0],
                start: q0,
                end: Array(a.end.union(b.end)),
                nodes: nodes
            )
        }

        func buildNFAKleene(_ a: NFA) -> NFA {
            var nodes = a.nodes
            
            for state in a.end {
                nodes[state, default: [:]]["", default: []].append(a.start)
            }

            let q0 = getId()
            nodes[q0] = ["": [a.start]]

            return NFA(
                alphabet: alphabet,
                states: Array(a.states) + [q0],
                start: q0,
                end: Array(a.end),
                nodes: nodes
            )
        }

        var current: Node? = output.head.next

        while let node = current {
            let val = node.val

            if ["|", "."].contains(val),
            let prev1 = node.prev,
            let prev2 = prev1.prev {
                
                let a = prev2.val
                let b = prev1.val

                let aNfa: NFA = prev2.nfa ?? {
                    prev2.nfa = buildNFALetter(a)
                    return prev2.nfa!
                }()

                let bNfa: NFA = prev1.nfa ?? {
                    prev1.nfa = buildNFALetter(b)
                    return prev1.nfa!
                }()
                
                switch val {
                case "|":
                    node.val = "(\(a)|\(b))"
                    node.nfa = buildNFAUnion(aNfa, bNfa)
                case ".":
                    node.val = "\(a)\(b)"
                    node.nfa = buildNFAConcat(aNfa, bNfa)
                default:
                    break
                }

                node.prev = prev2.prev
                node.prev?.next = node
            }
            
            else if ["*", "+", "?"].contains(val),
                let prev = node.prev {
                let a = prev.val

                let aNfa: NFA = prev.nfa ?? {
                    prev.nfa = buildNFALetter(a)
                    return prev.nfa!
                }()
                
                switch val {
                case "*":
                    node.val = "(\(a))*"
                    node.nfa = buildNFAKleene(aNfa)
                case "+":
                    node.val = "(\(a))+"
                case "?":
                    node.val = "(\(a))?"
                default:
                    break
                }

                node.prev = prev.prev
                node.prev?.next = node
            }

            current = node.next
        }
        
        return output.head.next!.nfa!
    }

    // ============================================================
    // TO STRING
    // ============================================================

    var description: String {
        func format(_ value: String) -> String {
            return value.isEmpty ? "ε" : value
        }

        let nodesDescription = nodes
            .sorted { $0.key < $1.key }
            .map { (state, transitions) -> String in
                let formattedTransitions = transitions
                    .sorted { $0.key < $1.key }
                    .map { symbol, target in
                        "  \(format(symbol)) → \(target.map(format))"
                    }
                    .joined(separator: "\n")

                return """
                \(format(state)):
                \(formattedTransitions)
                """
            }
            .joined(separator: "\n")

        return """
        States: \(states.sorted().map(format))
        Alphabet: \(alphabet.sorted().map(format))
        Start: \(format(start))
        End: \(end.sorted().map(format))

        Nodes:
        \(nodesDescription)
        """
    }
}

//var nfa = NFA(
//    alphabet: ["0", "1"],
//    states: ["q1", "q2", "q3"],
//    start: "q1",
//    end: ["q3"],
//    nodes: [
//        "q1": [
//            "0": ["q2", "q1"],
//            "1": ["q1"]
//        ],
//        "q2": [
//            "": ["q1"],
//            "1": ["q2"]
//        ],
//        "q3": [
//            "0": ["q3"],
//            "1": ["q1"]
//        ]
//    ]
//)

//nfa.discartUnusedStates()
//var dfa = nfa.toDfa()
//dfa.rename()
//print(dfa)

// let nfa = NFA.fromRegex(alphabet: ["a", "b", "c"], regex:"b|a")
// print(nfa)
