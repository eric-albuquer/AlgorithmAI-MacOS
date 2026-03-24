import SwiftUI

struct SortView: View {
    @State private var model: SortModel = SortModel(200)
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
                    
                    context.fill(
                        Path(rect),
                        with: .color(.green)
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
                    
                TextField("Digite um número", text: $text)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 200)

                Button("Resize") {
                    if let value = Int(text) {
                        model.resize(value)
                    }
                }

            }
            
            HStack {
                Button("Bubble Sort") {
                    bubbleSort(model)
                }
                
                Button("Quick Sort") {
                    quickSort(model)
                }
                
                Button("Merge Sort") {
                    mergeSort(model)
                }
                
                Button("Heap Sort") {
                    heapSort(model)
                }
                
                Button("Radix Sort") {
                    radixSort(model)
                }
                
                Button("Brute Force Sort") {
                    bruteForceSort(model)
                }
                
                Button("Bogo Sort") {
                    bogoSort(model)
                }
            }
        }
        .padding()
    }
}
