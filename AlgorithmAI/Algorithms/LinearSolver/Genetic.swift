import Darwin

func linearGenetic(_ model: LinearSolverModel){
    model.currentTask?.cancel()
    model.currentTask = Task {
        let population = 250
        var baseA = model.a
        var baseB = model.b
        var data: [(a: Double, b: Double)] = []
        
        var fitness = LinearSolverModel.dist(baseA, model.ta, baseB, model.tb)
            
        func genPop() {
            data = []
            for _ in 0..<population {
                data.append((
                    a: baseA + Double.random(in: -0.01...0.01),
                    b: baseB + Double.random(in: -0.01...0.01)
                ))
            }
        }
        
        func findBest() {
            for (a, b) in data {
                let d = LinearSolverModel.dist(a, model.ta, b, model.tb)
                if d < fitness {
                    fitness = d
                    baseA = a
                    baseB = b
                }
            }
        }
        
        while true {
            genPop()
            findBest()
            
            let ba = baseA
            let bb = baseB
            
            await MainActor.run {
                model.a = ba
                model.b = bb
            }
            
            let sleep = UInt64(100_000_000 * (1 - model.speed))
            try? await Task.sleep(nanoseconds: sleep)
            if Task.isCancelled { return }
        }
    }
}
