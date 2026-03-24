import Foundation

@Observable
class AutomatonModel: AlgorithmModel {
    var states: Set<String>
    var alphabet: Set<String>
    var nodes: [String:[String:[String]]]
    var start: String
    var end: Set<String>
    
    var cur: String
    var entry: String
    var idx: Int = 0
    
    init(states: [String], alphabet: [String], start: String, end: [String], nodes: [String:[String:[String]]], string: String) {
        self.states = Set(states)
        self.alphabet = Set(alphabet)
        self.start = start
        self.end = Set(end)
        self.nodes = nodes
        self.entry = string
        
        self.cur = start
        
        super.init()
    }
    
    func reset() {
        currentTask?.cancel()
        self.cur = start
        self.idx = 0
    }
    
    func newEntry() {
        currentTask?.cancel()
        self.idx = 0
        self.cur = start
        let a = Array(alphabet)
        self.entry = (0..<30).map{_ in a[Int.random(in: 0..<a.count)]}.joined()
    }
    
    func getEntry(_ entry: String) {
        currentTask?.cancel()
        self.idx = 0
        self.cur = start
        self.entry = entry
    }
    
    func getRegex(_ regex: String) {
        currentTask?.cancel()
        var alphabet: Set<String> = []
        
        for chr in regex {
            if ![" ", "|", "*", "(", ")"].contains(chr) {
                alphabet.insert(String(chr))
            }
        }
        
        self.alphabet = alphabet
        self.idx = 0
        self.cur = start
        self.entry = entry
    }
}
