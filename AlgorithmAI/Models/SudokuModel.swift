import Foundation

struct Cell {
    var collapsed = false
    var val: Int? = nil
    var states: Set<Int> = [1, 2, 3, 4, 5, 6, 7, 8, 9]
    
    mutating func collapse() -> Int {
        collapsed = true
        val = states.randomElement()
        return val!
    }
    
    mutating func remove(_ val: Int) {
        if collapsed {return}
        states.remove(val)
    }
}

@Observable
class SudokuModel: AlgorithmModel {
    var board = Array(repeating: Array(repeating: Cell(), count: 9), count: 9)
    
    override init(){
        super.init()
        speed = 0.01
    }
    
    func reset() {
        currentTask?.cancel()
        board = Array(repeating: Array(repeating: Cell(), count: 9), count: 9)
    }
}
