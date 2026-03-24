import SwiftUI

struct TSalesmanView: View {
    @State private var model: TSalesmanModel = TSalesmanModel(30)
    static private var pointSize: CGFloat = CGFloat(20)
    
    var body: some View {
        VStack {
            Text("Total cost: \(model.totalCost)")
                .font(.largeTitle.bold())
                .foregroundStyle(.white)
            
            Canvas { context, size in
                let radius = TSalesmanView.pointSize * 0.5
                var path = Path()
                let sx = model.points.first!.x * size.width + radius
                let sy = model.points.first!.y * size.height + radius
                path.move(to: CGPoint(x: sx, y: sy))
                
                for i in 1..<model.points.count {
                    let point = model.points[i]
                    let x = point.x * size.width
                    let y = point.y * size.height
                    
                    path.addLine(to: CGPoint(x: x + radius, y: y + radius))
                    
                    let rect = CGRect(
                        x: x,
                        y: y,
                        width: TSalesmanView.pointSize,
                        height: TSalesmanView.pointSize
                    )
                    
                    context.fill(
                        Path(ellipseIn: rect),
                        with: .color(.white)
                    )
                }
                
                context.stroke(path, with:.color(.blue), lineWidth: 2)
                
                let rectOrig = CGRect(
                    x: model.points.first!.x * size.width,
                    y: model.points.first!.y * size.height,
                    width: TSalesmanView.pointSize,
                    height: TSalesmanView.pointSize
                )
                
                context.fill(
                    Path(ellipseIn: rectOrig),
                    with: .color(.green)
                )
            }
            
            Slider(
                value: $model.speed,
                in: 0.01...0.99999
            )
            HStack {
                
                Button("Reset"){
                    model.reset()
                }
                
                Button("Shuffle"){
                    model.shuffle()
                }
            }
            
            HStack {
                Button("Closest Neighbour") {
                    closestNeighbour(model)
                }
                
                Button("Hill Climbing") {
                    hillClimbing(model)
                }
                
                Button("Hill Climbing Parallel") {
                    hillClimbingParallel(model)
                }
                
                Button("Brute Force") {
                    bruteForce(model)
                }

            }
        }
        .padding()
    }
}
