import SwiftUI

struct WordSearchView: View {
    @State private var model: WordSearchModel = WordSearchModel(20, 20)
    
    var body: some View {
        VStack {
            Canvas { context, size in
                let rows = model.matrix.count
                let cols = model.matrix[0].count
                
                let w: CGFloat = size.width / CGFloat(cols)
                let h: CGFloat = size.height / CGFloat(rows)
                
                for i in 0..<rows {
                    for j in 0..<cols {
                        let text = Text("\(model.matrix[i][j])")
                            .font(.system(size: min(w, h), weight: .bold))
                            .foregroundStyle(.white)
                        
                        let resolved = context.resolve(text)
                        
                        context.draw(
                            resolved,
                            at: CGPoint(
                                x: CGFloat(j) * w + w * 0.5,
                                y: CGFloat(i) * h + h * 0.5
                            ),
                            anchor: .center
                        )
                    }
                }
                
                for (x0, y0, x1, y1) in model.pos {
                    let dx = (x1 - x0).signum()
                    let dy = (y1 - y0).signum()
                    
                    var x = x0
                    var y = y0
                    
                    while true {
                        let rect = CGRect(
                            x: CGFloat(x) * w,
                            y: CGFloat(y) * h,
                            width: w,
                            height: h
                        )
                        
                        context.fill(
                            Path(rect),
                            with: .color(.yellow.opacity(0.3))
                        )
                        
                        if x == x1 && y == y1 { break }
                        
                        x += dx
                        y += dy
                    }
                }
                
                var rect = CGRect(
                    x: CGFloat(model.searchPos.x0) * w,
                    y: CGFloat(model.searchPos.y0) * h,
                    width: w,
                    height: h
                )
                
                context.fill(
                    Path(rect),
                    with: .color(.green.opacity(0.3))
                )
                
                rect = CGRect(
                    x: CGFloat(model.searchPos.x1) * w,
                    y: CGFloat(model.searchPos.y1) * h,
                    width: w,
                    height: h
                )
                
                context.fill(
                    Path(rect),
                    with: .color(.red.opacity(0.3))
                )
            }
            
            WordsView(words: model.words)
            
            Slider(
                value: $model.speed,
                in: 0.01...0.999
            )
            
            HStack {
                Button("Reset"){
                    model.reset()
                }
            }
            
            HStack {
                Button("Trie Search"){
                    trieSearch(model)
                }
            }
        }
        .padding()
    }
}

struct WordsView: View {
    let words: [String]
    
    let columns = [
        GridItem(.adaptive(minimum: 80), spacing: 8)
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(words, id: \.self) { word in
                    Text(word)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.blue.opacity(0.2))
                        .cornerRadius(8)
                }
            }
        }
        .frame(height: 60) // controla espaço
    }
}
