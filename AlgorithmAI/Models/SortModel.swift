import Foundation

@Observable
class SortModel: AlgorithmModel {
    var array: [Int] = []
    
    init(_ size: Int) {
        super.init()
        array = (1...size).shuffled()
    }
    
    func resize(_ size: Int) {
        currentTask?.cancel()
        array = (1...size).shuffled()
    }
    
    func shuffle(){
        currentTask?.cancel()
        array.shuffle()
    }
}
