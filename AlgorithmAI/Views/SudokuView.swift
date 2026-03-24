import SwiftUI

struct SudokuView: View {
    
    @State private var model = SudokuModel()
    
    var body: some View {
        VStack {
            
            Canvas { context, size in
                
                let cellSize = min(size.width, size.height) / 9
                let small = cellSize / 3
                
                // MARK: - Background
                context.fill(
                    Path(CGRect(origin: .zero, size: size)),
                    with: .color(.black)
                )
                
                // MARK: - Cells
                for row in 0..<9 {
                    for col in 0..<9 {
                        
                        let x = CGFloat(col) * cellSize
                        let y = CGFloat(row) * cellSize
                        
                        let rect = CGRect(x: x, y: y, width: cellSize, height: cellSize)
                        let cell = model.board[row][col]
                        
                        // Highlight collapsed cells
                        if cell.collapsed {
                            context.fill(
                                Path(rect),
                                with: .color(.blue.opacity(0.15))
                            )
                        }
                        
                        // MARK: - Collapsed value
                        if cell.collapsed {
                            
                            let text = Text("\(cell.val!)")
                                .font(.system(size: cellSize * 0.6, weight: .bold))
                                .foregroundStyle(.white)
                            
                            let resolved = context.resolve(text)
                            
                            context.draw(
                                resolved,
                                at: CGPoint(
                                    x: x + cellSize/2,
                                    y: y + cellSize/2
                                ),
                                anchor: .center
                            )
                            
                        } else {
                            
                            // MARK: - Superposition candidates
                            
                            let states = Array(cell.states).sorted()
                            
                            for s in states {
                                
                                let i = (s - 1) % 3
                                let j = (s - 1) / 3
                                
                                let text = Text("\(s)")
                                    .font(.system(size: cellSize * 0.18))
                                    .foregroundStyle(.gray)
                                
                                let resolved = context.resolve(text)
                                
                                context.draw(
                                    resolved,
                                    at: CGPoint(
                                        x: x + CGFloat(i) * small + small/2,
                                        y: y + CGFloat(j) * small + small/2
                                    ),
                                    anchor: .center
                                )
                            }
                        }
                    }
                }
                
                // MARK: - Grid lines
                
                for i in 0...9 {
                    
                    let pos = CGFloat(i) * cellSize
                    
                    var path = Path()
                    path.move(to: CGPoint(x: pos, y: 0))
                    path.addLine(to: CGPoint(x: pos, y: cellSize * 9))
                    
                    context.stroke(
                        path,
                        with: .color(.white),
                        lineWidth: i % 3 == 0 ? 3 : 1
                    )
                    
                    var path2 = Path()
                    path2.move(to: CGPoint(x: 0, y: pos))
                    path2.addLine(to: CGPoint(x: cellSize * 9, y: pos))
                    
                    context.stroke(
                        path2,
                        with: .color(.white),
                        lineWidth: i % 3 == 0 ? 3 : 1
                    )
                }
            }
            .aspectRatio(1, contentMode: .fit)
            
            Slider(
                value: $model.speed,
                in: 0.0001...0.9
            )
            
            HStack {
                Button("Reset") {
                    model.reset()
                }
            }
            
            HStack {
                Button("Wave Function Collapse") {
                    waveCollapse(model)
                }
                
                Button("Sudoku Backtracking") {
                    sudokuBacktracking(model)
                }
            }
        }
        .padding()
        .background(Color.black)
    }
}
