struct MazeHeap {
    var data: [MazeNode] = []
    
    mutating func add(_ node: MazeNode) {
        var i = data.count
        data.append(node)
        
        while i > 0 {
            let p = (i - 1) >> 1
            if data[p].f <= data[i].f {break}
            data.swapAt(i, p)
            i = p
        }
    }
    
    mutating func get() -> MazeNode {
        let n = data.count - 1
        let node = data[0]
        
        data[0] = data[n]
        data.removeLast()
        
        var i = 0
        while true {
            let l = (i << 1) | 1
            let r = l + 1
            
            var m = i
            
            if l < n && data[l].f < data[m].f {m = l}
            if r < n && data[r].f < data[m].f {m = r}
            
            if m == i {break}
            data.swapAt(i, m)
            i = m
        }
        
        return node
    }
}

func mDist(_ x0: Int, _ y0: Int, _ x1: Int, _ y1: Int) -> Int {
    return abs(x1 - x0) + abs(y1 - y0)
}

func AStar(_ model: PathFindingModel) {
    model.currentTask?.cancel()
    model.clearVisited()
    model.currentTask = Task {
        let rows = model.matrix.count
        let cols = model.matrix[0].count
        
        let x0 = model.x0
        let y0 = model.y0
        let x1 = model.x1
        let y1 = model.y1
        
        var heap = MazeHeap()
        let startNode = MazeNode(x: x0, y: y0, g: 0, h: mDist(x0, y0, x1, y1))
        heap.add(startNode)
        await MainActor.run {
            model.visited[y0][x0] = startNode
        }
        
        let dx = [1, -1, 0, 0]
        let dy = [0, 0, 1, -1]
        
        while heap.data.count > 0 {
            let n = heap.get()
            let x = n.x
            let y = n.y
            
            let best = await MainActor.run {
                model.visited[y][x]
            }
            if best != nil && best !== n {continue}
            
            if x == x1 && y == y1 {return}
            
            let ng = n.g + 1
            
            let sleep = UInt64(100_000_000 * (1 - model.speed))
            if Task.isCancelled { return }
            try? await Task.sleep(nanoseconds: sleep)
            
            for i in 0...3 {
                if Task.isCancelled { return }
                let nx = x + dx[i]
                let ny = y + dy[i]
                
                if nx < 0 || nx >= cols || ny < 0 || ny >= rows {continue}
                if model.matrix[ny][nx] {continue}
                
                let best = await MainActor.run {
                    model.visited[ny][nx]
                }
                    
                if best != nil && best!.g <= ng { continue }
                
                let node = MazeNode(x: nx, y: ny, g: ng, h: mDist(nx, ny, x1, y1), prev: n)
                await MainActor.run {
                    model.visited[ny][nx] = node
                }
                
                heap.add(node)
            }
        }
    }
}
