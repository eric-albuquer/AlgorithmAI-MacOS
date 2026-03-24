class Node {
    var isWord = false
    var next: [Node?] = Array(repeating: nil, count: 26)
}

struct Trie {
    var root: [Node?] = Array(repeating: nil, count: 26)
    
    init(_ words: [String]) {
        for w in words {
            addWord(w)
        }
    }
    
    mutating func addWord(_ word: String) {
        let w = Array(word)
        let idx = Int(w[0].asciiValue! - 97)
        if root[idx] == nil {root[idx] = Node()}
        var cur: Node = root[idx]!
        
        for i in 1..<w.count {
            let j = Int(w[i].asciiValue! - 97)
            if cur.next[j] == nil {cur.next[j] = Node()}
            cur = cur.next[j]!
        }
        
        cur.isWord = true
    }
}

func trieSearch(_ model: WordSearchModel){
    model.currentTask?.cancel()
    model.currentTask = Task {
        let trie = Trie(model.words)
        let rows = model.matrix.count
        let cols = model.matrix[0].count
        
        let dirX = [0, 0, -1, 1, 1, 1, -1, -1]
        let dirY = [-1, 1, 0, 0, 1, -1, 1, -1]
        
        for i in 0..<rows {
            for j in 0..<cols {
                let sleep = UInt64(100_000_000 * (1 - model.speed))
                try? await Task.sleep(nanoseconds: sleep)
                if Task.isCancelled { return }
                
                let x0 = j
                let y0 = i
                await MainActor.run {
                    model.searchPos.x0 = x0
                    model.searchPos.y0 = y0
                }
                
                for k in 0..<8 {
                    let dx = dirX[k]
                    let dy = dirY[k]
                    
                    var y = i
                    var x = j
                    
                    var c = model.matrix[y][x]
                    var idx = Int(c.asciiValue! - 97)
                    var cur = trie.root[idx]
                    
                    if cur == nil {continue}
                    
                    while cur != nil {
                        let sleep = UInt64(500_000_000 * (1 - model.speed))
                        try? await Task.sleep(nanoseconds: sleep)
                        if Task.isCancelled { return }
                        
                        let x2 = x
                        let y2 = y
                        
                        let curCopy = cur
                        await MainActor.run {
                            if curCopy!.isWord {
                                model.pos.append((x0: j, y0: i, x1: x2, y1: y2))
                            }
                        }
                        
                        y += dy
                        x += dx
                        
                        let x1 = x
                        let y1 = y
                        await MainActor.run {
                            model.searchPos.x1 = x1
                            model.searchPos.y1 = y1
                        }
                        
                        try? await Task.sleep(nanoseconds: sleep)
                        if Task.isCancelled { return }
                        
                        if x < 0 || x >= cols || y < 0 || y >= rows {break}
                        
                        c = model.matrix[y][x]
                        idx = Int(c.asciiValue! - 97)
                        cur = cur?.next[idx]
                    }
                }
            }
        }
    }
}
