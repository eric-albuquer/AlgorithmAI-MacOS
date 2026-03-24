import SwiftUI

struct RenderView: View {
    @State private var model: RenderModel = RenderModel(1100, 500)
    
    var body: some View {
        VStack {
            Text(model.loaded ? "" : "Loading...").font(.system(.title, design: .monospaced))
                .foregroundStyle(.yellow)
            
            Canvas { context, size in
                if let cgImage = model.makeImage() {
                    context.draw(
                        Image(decorative: cgImage, scale: 1.0),
                        in: CGRect(origin: .zero, size: size)
                    )
                }
            }
            
            Slider(
                value: $model.speed,
                in: 0.01...0.999
            )
            
            Button("Clear") {
                model.reset()
            }
            
            HStack {
                Button("CPU Render") {
                    cpuRender(model)
                }
                
                Button("GPU Render") {
                    cpuRender(model, true)
                }
            }
        }
        .task {
            await model.loadAsync()
        }
        .padding()
    }
}

#Preview {
    RenderView()
}
