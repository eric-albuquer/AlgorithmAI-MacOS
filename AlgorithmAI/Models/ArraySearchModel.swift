import Foundation

@Observable
class ArraySearchModel: AlgorithmModel {
    var array: [Int] = []
    var element: Int = 0
    var minIdx: Int
    var maxIdx: Int
    var midIdx: Int
    
    init(_ size: Int) {
        minIdx = 0
        maxIdx = 0
        midIdx = 0
        element = Int.random(in: 1...size)
        super.init()
        array = Array(1...size)
    }
    
    func reset() {
        minIdx = 0
        maxIdx = 0
        midIdx = 0
    }
    
    func shuffle(){
        currentTask?.cancel()
        reset()
        array.shuffle()
    }
    
    func sort() {
        currentTask?.cancel()
        reset()
        array.sort()
    }
    
    func setElement(_ e: Int) {
        currentTask?.cancel()
        reset()
        element = e
    }
    
    func randomElement() {
        currentTask?.cancel()
        reset()
        element = Int.random(in: 1...array.count)
    }
}
