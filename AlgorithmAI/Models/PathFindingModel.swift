import Foundation

class MazeNode {
    var x: Int
    var y: Int
    var g: Int
    var h: Int
    var f: Int
    var prev: MazeNode? = nil
    
    init(x: Int, y: Int, g: Int = 0, h: Int = 0, prev: MazeNode? = nil) {
        self.x = x
        self.y = y
        self.g = g
        self.h = h
        self.f = g + h
        self.prev = prev
    }
}

@Observable
class PathFindingModel: AlgorithmModel {
    var matrix: [[Bool]]
    var visited: [[MazeNode?]]
    var x0: Int
    var y0: Int
    var x1: Int
    var y1: Int
    
    init(_ rows: Int, _ cols: Int){
        let r = rows | 1
        let c = cols | 1
        matrix = Array(repeating: Array(repeating: false, count: c), count: r)
        visited = Array(repeating: Array(repeating: nil, count: c), count: r)
        
        x0 = Int.random(in: 1...c-2) | 1
        y0 = Int.random(in: 1...c-2) | 1
        x1 = Int.random(in: 1...c-2) | 1
        y1 = Int.random(in: 1...c-2) | 1
    }
    
    func setSize(_ rows: Int, _ cols: Int){
        let r = rows | 1
        let c = cols | 1
        matrix = Array(repeating: Array(repeating: false, count: c), count: r)
        
        clearVisited()
        changePoints()
    }
    
    func clearVisited() {
        visited = Array(repeating: Array(repeating: nil, count: matrix[0].count), count: matrix.count)
    }
    
    func changePoints(){
        currentTask?.cancel()
        let r = matrix.count
        let c = matrix[0].count
        
        x0 = Int.random(in: 1...c-2) | 1
        y0 = Int.random(in: 1...c-2) | 1
        x1 = Int.random(in: 1...c-2) | 1
        y1 = Int.random(in: 1...c-2) | 1
        
        visited = Array(repeating: Array(repeating: nil, count: c), count: r)
    }
    
    func generateMaze() {
        currentTask?.cancel()
        let rows = matrix.count
        let cols = matrix[0].count
        
        visited = Array(repeating: Array(repeating: nil, count: cols), count: rows)
        
        // Inicializa tudo como parede
        for r in 0..<rows {
            for c in 0..<cols {
                matrix[r][c] = true
            }
        }
        
        var stack: [(Int, Int)] = []
        
        let start = (1, 1)
        matrix[start.0][start.1] = false
        stack.append(start)
        
        let directions = [
            (0, 2),
            (0, -2),
            (2, 0),
            (-2, 0)
        ]
        
        while !stack.isEmpty {
            
            let current = stack.last!
            var neighbors: [(Int, Int)] = []
            
            for (dr, dc) in directions {
                let nr = current.0 + dr
                let nc = current.1 + dc
                
                if nr > 0 && nr < rows-1 &&
                   nc > 0 && nc < cols-1 &&
                   matrix[nr][nc] {
                    
                    neighbors.append((nr, nc))
                }
            }
            
            if let next = neighbors.randomElement() {
                
                let wallR = (current.0 + next.0) / 2
                let wallC = (current.1 + next.1) / 2
                
                matrix[wallR][wallC] = false
                matrix[next.0][next.1] = false
                
                stack.append(next)
                
            } else {
                stack.removeLast()
            }
        }
        
        // Abrir algumas paredes extras para criar múltiplos caminhos
        let extraOpenings = (rows * cols) / 10

        for _ in 0..<extraOpenings {
            
            let r = Int.random(in: 1..<rows-1)
            let c = Int.random(in: 1..<cols-1)
            
            if matrix[r][c] == true {
                
                let vertical = r % 2 == 0 && c % 2 == 1
                let horizontal = r % 2 == 1 && c % 2 == 0
                
                if vertical {
                    if !matrix[r-1][c] && !matrix[r+1][c] {
                        matrix[r][c] = false
                    }
                }
                
                if horizontal {
                    if !matrix[r][c-1] && !matrix[r][c+1] {
                        matrix[r][c] = false
                    }
                }
            }
        }
    }
}
