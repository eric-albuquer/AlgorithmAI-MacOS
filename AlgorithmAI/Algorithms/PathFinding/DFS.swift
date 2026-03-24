func dfs(_ model: PathFindingModel) {
    model.currentTask?.cancel()
    model.clearVisited()
    
    model.currentTask = Task {
        
        let rows = model.matrix.count
        let cols = model.matrix[0].count
        
        let x0 = model.x0
        let y0 = model.y0
        let x1 = model.x1
        let y1 = model.y1
        
        var stack: [MazeNode] = []
        let startNode = MazeNode(x: x0, y: y0)
        
        stack.append(startNode)
        
        await MainActor.run {
            model.visited[y0][x0] = startNode
        }
        
        let dx = [1, -1, 0, 0]
        let dy = [0, 0, 1, -1]
        
        while !stack.isEmpty {
            
            let n = stack.removeLast()
            let x = n.x
            let y = n.y
            
            let sleep = UInt64(Double(100_000_000) * (1 - model.speed))
            
            if Task.isCancelled { return }
            try? await Task.sleep(nanoseconds: sleep)
            
            for i in 0..<4 {
                if Task.isCancelled { return }
                
                let nx = x + dx[i]
                let ny = y + dy[i]
                
                if nx < 0 || nx >= cols || ny < 0 || ny >= rows { continue }
                if model.matrix[ny][nx] { continue }
                if model.visited[ny][nx] != nil { continue }
                
                let node = MazeNode(x: nx, y: ny, prev: n)
                
                await MainActor.run {
                    model.visited[ny][nx] = node
                }
                
                if nx == x1 && ny == y1 {
                    return
                }
                
                stack.append(node)
            }
        }
    }
}
