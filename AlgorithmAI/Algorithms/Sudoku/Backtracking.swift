func isValid(_ board: [[Cell]], _ r: Int, _ c: Int, _ v: Int) -> Bool {
    
    for i in 0..<9 {
        if board[r][i].val == v { return false }
        if board[i][c].val == v { return false }
    }
    
    let br = (r / 3) * 3
    let bc = (c / 3) * 3
    
    for i in 0..<3 {
        for j in 0..<3 {
            if board[br + i][bc + j].val == v {
                return false
            }
        }
    }
    
    return true
}

func sudokuBacktracking(_ model: SudokuModel) {
    
    model.currentTask?.cancel()
    model.currentTask = Task {
        
        func solve(_ r: Int, _ c: Int) async -> Bool {
            
            if Task.isCancelled { return false }
            
            if r == 9 { return true }
            
            let nr = c == 8 ? r + 1 : r
            let nc = c == 8 ? 0 : c + 1
            
            if model.board[r][c].collapsed {
                return await solve(nr, nc)
            }
            
            for v in 1...9 {
                
                if !isValid(model.board, r, c, v) { continue }
                
                await MainActor.run {
                    model.board[r][c].collapsed = true
                    model.board[r][c].val = v
                }
                
                let sleep = UInt64(50_000_000 * (1 - model.speed))
                try? await Task.sleep(nanoseconds: sleep)
                
                if await solve(nr, nc) {
                    return true
                }
                
                await MainActor.run {
                    model.board[r][c].collapsed = false
                    model.board[r][c].val = nil
                }
            }
            
            return false
        }
        
        _ = await solve(0,0)
    }
}
