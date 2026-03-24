import SwiftUI

struct ArraySearchView: View {
    @State private var model: ArraySearchModel = ArraySearchModel(100)
    @State private var text = ""
    
    var body: some View {
        VStack {
            Canvas { context, size in
                let n = CGFloat(model.array.count)
                let width = size.width / n
                
                for (i, value) in model.array.enumerated() {
                    let height = CGFloat(value) / n * size.height
                    
                    let rect = CGRect(
                        x: CGFloat(i) * width,
                        y: size.height - height,
                        width: width * 0.9,
                        height: height
                    )
                    
                    let color: GraphicsContext.Shading

                    if value == model.element {
                        color = .color(.red)
                    } else if i == model.maxIdx {
                        color = .color(.blue)
                    } else if i == model.minIdx {
                        color = .color(.orange)
                    } else if i == model.midIdx {
                        color = .color(.purple)
                    } else {
                        color = .color(.green)
                    }

                    context.fill(
                        Path(rect),
                        with: color
                    )
                }
            }
            
            Slider(
                value: $model.speed,
                in: 0.01...0.999
            )
            
            
            HStack {
                Button("Shuffle"){
                    model.shuffle()
                }
                
                Button("Sort"){
                    model.sort()
                }
                
                Button("Random Element"){
                    model.randomElement()
                }
                
                TextField("Digite um número", text: $text)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 200)

                Button("Set element") {
                    if let value = Int(text) {
                        model.setElement(value)
                    }
                }
            }
            
            HStack {
                Button("Linear Search") {
                    linearSearch(model)
                }
                
                Button("Binary Search") {
                    binarySearch(model)
                }
                
                Button("Quick Select") {
                    quickSelect(model)
                }
            }
        }
        .padding()
    }
}
