struct MazeQueue {
    var data: [MazeNode?]
    var head: Int = 0
    var tail: Int = 0
    
    let mask: Int
    
    init(_ count: Int) {
        var c = count
        c -= 1
        c |= c >> 1
        c |= c >> 2
        c |= c >> 4
        c |= c >> 8
        c |= c >> 16
        c += 1
        
        mask = c - 1
        data = Array(repeating: nil, count: c)
    }
    
    mutating func enqueue(_ node: MazeNode){
        data[head & mask] = node
        head += 1
    }
    
    mutating func dequeue() -> MazeNode {
        let node = data[tail & mask]
        tail += 1
        return node!
    }
    
    func count() -> Int {
        return head - tail
    }
}

func bfs(_ model: PathFindingModel) {
    model.currentTask?.cancel()
    model.clearVisited()
    model.currentTask = Task {
        let rows = model.matrix.count
        let cols = model.matrix[0].count
        
        let x0 = model.x0
        let y0 = model.y0
        let x1 = model.x1
        let y1 = model.y1
        
        var queue = MazeQueue(rows * cols)
        let startNode = MazeNode(x: x0, y: y0)
        queue.enqueue(startNode)
        await MainActor.run {
            model.visited[y0][x0] = startNode
        }
        
        let dx = [1, -1, 0, 0]
        let dy = [0, 0, 1, -1]
        
        while queue.count() > 0 {
            let n = queue.dequeue()
            let x = n.x
            let y = n.y
            
            let sleep = UInt64(100_000_000 * (1 - model.speed))
            if Task.isCancelled { return }
            try? await Task.sleep(nanoseconds: sleep)
            
            for i in 0...3 {
                if Task.isCancelled { return }
                let nx = x + dx[i]
                let ny = y + dy[i]
                
                if nx < 0 || nx >= cols || ny < 0 || ny >= rows {continue}
                if model.matrix[ny][nx] {continue}
                if model.visited[ny][nx] != nil {continue}
                
                let node = MazeNode(x: nx, y: ny, prev: n)
                await MainActor.run {
                    model.visited[ny][nx] = node
                }
                if nx == x1 && ny == y1 {return}
                
                queue.enqueue(node)
            }
        }
    }
}
