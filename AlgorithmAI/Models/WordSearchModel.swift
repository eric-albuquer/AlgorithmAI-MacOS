import Foundation

@Observable
class WordSearchModel : AlgorithmModel {
    var matrix: [[Character]]
    var words: [String] = []
    var pos: [(x0: Int, y0: Int, x1: Int, y1: Int)] = []
    var searchPos: (x0: Int, y0: Int, x1: Int, y1: Int) = (-1, -1, -1, -1)
    
    init(_ rows: Int, _ cols: Int) {
        self.matrix = (0..<rows).map { _ in
            (0..<cols).map { _ in
                Character(UnicodeScalar(Int.random(in: 97...122))!)
            }
        }
        
        super.init()
        self.reset()
    }
    
    func reset() {  
        currentTask?.cancel()
        pos = []
        searchPos = (-1, -1, -1, -1)
        let rows = self.matrix.count
        let cols = self.matrix[0].count
        self.matrix = (0..<rows).map { _ in
            (0..<cols).map { _ in
                Character(UnicodeScalar(Int.random(in: 97...122))!)
            }
        }
        
        guard let url = Bundle.main.url(forResource: "palavras", withExtension: "txt") else {
            print("arquivo não encontrado")
            return
        }
        
        var used = Array(repeating: Array(repeating: false, count: cols), count: rows)
        
        let dirX = [0, 0, -1, 1, 1, 1, -1, -1]
        let dirY = [-1, 1, 0, 0, 1, -1, 1, -1]
        
        do {
            let text = try String(contentsOf: url, encoding: .utf8)
            
            for line in text.split(separator: "\n") {
                let count = line.count
                let idx = Int.random(in: 0..<8)
                let dx = dirX[idx]
                let dy = dirY[idx]
                
                let minX = dx == -1 ? count : 0
                let maxX = dx == 1 ? cols - count : cols
                
                let minY = dy == -1 ? count : 0
                let maxY = dy == 1 ? rows - count : rows
                
                var valid = true
                
                for _ in 0..<100 {
                    valid = true
                    
                    let x = Int.random(in: minX..<maxX)
                    let y = Int.random(in: minY..<maxY)
                    
                    for (i, l) in line.enumerated() {
                        let yIdx = y + dy * i
                        let xIdx = x + dx * i
                        if used[yIdx][xIdx] && matrix[yIdx][xIdx] != l {
                            valid = false
                            break
                        }
                    }
                    
                    if !valid {continue}
                    
                    for (i, l) in line.enumerated() {
                        let yIdx = y + dy * i
                        let xIdx = x + dx * i
                        matrix[yIdx][xIdx] = l
                        used[yIdx][xIdx] = true
                    }
                    
                    //print(x, y, line)
                    break
                }
                
                if valid {words.append(String(line))}
            }
            
        } catch {
            print("erro ao ler arquivo")
            return
        }
    }
}
