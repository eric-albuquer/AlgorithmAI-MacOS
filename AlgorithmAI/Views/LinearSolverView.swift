import SwiftUI

struct LinearSolverView: View {
    @State private var model: LinearSolverModel = LinearSolverModel()
    
    var body: some View {
        VStack {
            Canvas { context, size in
                
                let minX: CGFloat = -10
                let maxX: CGFloat = 10
                let minY: CGFloat = -10
                let maxY: CGFloat = 10
                
                func mapX(_ x: CGFloat) -> CGFloat {
                    (x - minX) / (maxX - minX) * size.width
                }
                
                func mapY(_ y: CGFloat) -> CGFloat {
                    size.height - (y - minY) / (maxY - minY) * size.height
                }
                
                // MARK: - Draw axes
                
                var axis = Path()
                
                axis.move(to: CGPoint(x: mapX(0), y: 0))
                axis.addLine(to: CGPoint(x: mapX(0), y: size.height))
                
                axis.move(to: CGPoint(x: 0, y: mapY(0)))
                axis.addLine(to: CGPoint(x: size.width, y: mapY(0)))
                
                context.stroke(axis, with: .color(.gray), lineWidth: 1)
                
                
                // MARK: - Target line
                
                var path = Path()
                
                for x in stride(from: minX, through: maxX, by: 0.1) {
                    let y = model.ta * x + model.tb
                    
                    let px = mapX(x)
                    let py = mapY(y)
                    
                    if x == minX {
                        path.move(to: CGPoint(x: px, y: py))
                    } else {
                        path.addLine(to: CGPoint(x: px, y: py))
                    }
                }
                
                context.stroke(path, with: .color(.blue), lineWidth: 2)
                
                
                // MARK: - Genetic line
                
                path = Path()
                
                for x in stride(from: minX, through: maxX, by: 0.1) {
                    let y = model.a * x + model.b
                    
                    let px = mapX(x)
                    let py = mapY(y)
                    
                    if x == minX {
                        path.move(to: CGPoint(x: px, y: py))
                    } else {
                        path.addLine(to: CGPoint(x: px, y: py))
                    }
                }
                
                context.stroke(path, with: .color(.green), lineWidth: 2)
            }
            
            Slider(
                value: $model.speed,
                in: 0.01...0.999
            )
            
            Button("Reset"){
                model.reset()
            }
            
            HStack {
                Button("Genetic") {
                    linearGenetic(model)
                }
                
                Button("Gradient Descent") {
                    linearGradientDescent(model)
                }
            }
        }
        .padding()
    }
}
