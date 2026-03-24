func waveCollapse(_ model: SudokuModel){
    model.currentTask?.cancel()
    model.currentTask = Task {
        
        func collapseCell(_ y: Int, _ x: Int) async {
            let v = model.board[y][x].collapse()
            
            for k in 0..<9 {
                model.board[k][x].remove(v)
                model.board[y][k].remove(v)
            }
            
            let sx = (x / 3) * 3
            let sy = (y / 3) * 3
            
            for i in 0..<3 {
                for j in 0..<3 {
                    model.board[sy+i][sx+j].remove(v)
                }
            }
        }
        
        func getMinCellIdx() async -> (y: Int, x: Int)? {
            var idx: [(y: Int, x: Int)] = []
            var minCount = 9
            for i in 0..<9 {
                for j in 0..<9 {
                    let cell = model.board[i][j]
                    if cell.collapsed {continue}
                    let count = cell.states.count
                    if count < minCount && count > 0 {
                        minCount = count
                        idx = []
                    }
                    if count == minCount {
                        idx.append((y: i, x: j))
                    }
                }
            }
            return idx.randomElement()
        }
        
        for _ in 0..<81 {
            if let pos = await getMinCellIdx() {
                await collapseCell(pos.y, pos.x)
            } else { break }
                    
            let sleep = UInt64(100_000_000 * (1 - model.speed))
            try? await Task.sleep(nanoseconds: sleep)
            if Task.isCancelled { return }
        }
    }
}
