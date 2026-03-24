func linearGradientDescent(_ model: LinearSolverModel) {
    model.currentTask?.cancel()
    
    model.currentTask = Task {
        
        var a = model.a
        var b = model.b
        
        let ta = model.ta
        let tb = model.tb
        
        let lr = 0.01
        
        while true {
            
            if Task.isCancelled { return }
            
            // Gradientes
            let da = 2 * (a - ta)
            let db = 2 * (b - tb)
            
            // Atualização
            a -= lr * da
            b -= lr * db
            
            // Atualiza visualização
            let na = a
            let nb = b
            
            await MainActor.run {
                model.a = na
                model.b = nb
            }
            
            let sleep = UInt64(100_000_000 * (1 - model.speed))
            try? await Task.sleep(nanoseconds: sleep)
        }
    }
}
