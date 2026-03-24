import SwiftUI

struct PathfindingView: View {
    
    @State private var model = PathFindingModel(45, 80)
    
    var body: some View {
        
        VStack {
            
            Canvas { context, size in
                
                let rows = model.matrix.count
                let cols = model.matrix[0].count
                
                let cellWidth = size.width / CGFloat(cols)
                let cellHeight = size.height / CGFloat(rows)
                
                for r in 0..<rows {
                    for c in 0..<cols {
                        
                        let rect = CGRect(
                            x: CGFloat(c) * cellWidth,
                            y: CGFloat(r) * cellHeight,
                            width: cellWidth,
                            height: cellHeight
                        )
                        
                        let color: Color = model.visited[r][c] != nil ? .blue : model.matrix[r][c] ? .black : .white
                        
                        context.fill(
                            Path(rect),
                            with: .color(color)
                        )
                    }
                }
                
                var cur = model.visited[model.y1][model.x1]
                while let node = cur {
                    
                    let rectPath = CGRect(
                        x: CGFloat(node.x) * cellWidth,
                        y: CGFloat(node.y) * cellHeight,
                        width: cellWidth,
                        height: cellHeight
                    )
                    
                    context.fill(
                        Path(rectPath),
                        with: .color(.yellow)
                    )
                    
                    cur = node.prev
                }
                
                let rectOrigin = CGRect(
                    x: CGFloat(model.x0) * cellWidth,
                    y: CGFloat(model.y0) * cellHeight,
                    width: cellWidth,
                    height: cellHeight
                )
                
                context.fill(
                    Path(rectOrigin),
                    with: .color(.green)
                )
                
                let rectDest = CGRect(
                    x: CGFloat(model.x1) * cellWidth,
                    y: CGFloat(model.y1) * cellHeight,
                    width: cellWidth,
                    height: cellHeight
                )
                
                context.fill(
                    Path(rectDest),
                    with: .color(.red)
                )
            }
            
            Slider(
                value: $model.speed,
                in: 0.01...0.999
            )
            
            HStack {
                
                Button("Generate Maze") {
                    model.generateMaze()
                }
                
                Button("Change Poits") {
                    model.changePoints()
                }
            }
            
            HStack {
                
                Button("BFS") {
                    bfs(model)
                }
                
                Button("DFS") {
                    dfs(model)
                }
                
                Button("A*") {
                    AStar(model)
                }
            }
        }
        .padding()
    }
}
