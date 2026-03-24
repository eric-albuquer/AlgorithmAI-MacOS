func fromRegex(regex: String, model: AutomatonModel) {
    model.currentTask?.cancel()
    model.currentTask = Task {
        let regexClean = regex.replacingOccurrences(of: " ", with: "")
        var aSet: Set<String> = []
        for chr in regexClean {
            if !["|", "*", "(", ")"].contains(chr) {
                aSet.insert(String(chr))
            }
        }
        let alphabet = Array(aSet)
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
        
        let tokens = addConcat(regexClean)
        
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
        var states: Set<String> = []
        
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
            
            if let nfa = node.nfa {
                states.formUnion(nfa.states)
                let s = states
                await MainActor.run {
                    model.nodes = nfa.nodes
                    model.states = s
                }
            }
            
            
            let sleep = UInt64(1_000_000_000 * (1 - model.speed))
            try? await Task.sleep(nanoseconds: sleep)
            if Task.isCancelled { return }
            current = node.next
        }
        let nfa: NFA = output.head.next!.nfa!
        
        await MainActor.run {
            model.nodes = nfa.nodes
            model.alphabet = nfa.alphabet
            model.states = nfa.states
            model.start = nfa.start
            model.end = nfa.end
            
            model.newEntry()
        }
        
        //return output.head.next!.nfa!
    }
}
