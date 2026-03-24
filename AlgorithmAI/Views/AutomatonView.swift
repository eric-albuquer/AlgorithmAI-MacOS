import SwiftUI
import Darwin

struct AutomatonView: View {
    @State private var model: AutomatonModel = AutomatonModel(
        states: ["q0", "q1", "q2"] ,
        alphabet: ["0", "1"],
        start: "q0",
        end: ["q2"],
        nodes: [
            
            "q0": [
                "0": ["q1"],
            ],
            
            "q1": [
                "0": ["q1"],
                "1": ["q2"]
            ],
            
            "q2": [
                "1": ["q2"],
            ]
        ],
        
        string: "00010100110010111110"
    )
    @State private var text = ""
    
    var body: some View {
        VStack {
            let start = model.entry.index(model.entry.startIndex, offsetBy: model.idx)
            let end = model.entry.index(start, offsetBy: min(100, model.entry.count - model.idx))
            let sub = String(model.entry[start..<end])
            Text("\(sub)").font(.system(.title, design: .monospaced))
                .foregroundStyle(.yellow)
            
            Canvas { context, size in
                let n = model.states.count
                let centerX = size.width * 0.5
                let centerY = size.height * 0.5
                let radius = min(size.width, size.height) * 0.4
                let dAngle = 2 * Double.pi / Double(n)
                let circleRadius = radius / 8
                let circleDiameter = circleRadius * 2
                let fontSize = circleRadius * 0.7
                
                var nodes: [String: Point] = [:]
                
                var i: Double = Double.pi * 0.5
                for qName in model.states {
                    let angle = i * dAngle
                    let x = centerX + cos(angle) * radius
                    let y = centerY + sin(angle) * radius
                    
                    nodes[qName] = Point(x: x, y: y)
                    
                    i += 1
                }
                
                for qName in model.states {
                    let adj: [String:[String]] = model.nodes[qName] ?? [:]
                    let p = nodes[qName]
                    let x0 = p!.x + circleRadius
                    let y0 = p!.y + circleRadius
                    
                    let angle = atan2(y0 - centerY, x0 - centerX)
                    
                    if model.start == qName {
                        let size = circleDiameter * 3.5
                        var path = Path()
                        path.move(to: CGPoint(x: x0, y: y0))
                        path.addLine(to: CGPoint(x: x0 + cos(angle) * size, y: y0 + sin(angle) * size))
                        context.stroke(path, with: .color(.orange), lineWidth: 3)
                    }
                    
                    if model.end.contains(qName){
                        context.fill(Path(ellipseIn: CGRect(
                            x: x0 - circleRadius * 1.25,
                            y: y0 - circleRadius * 1.25,
                            width: circleRadius * 2.5,
                            height: circleRadius * 2.5
                        )), with: .color(.yellow))
                    }
                                
                    context.fill(Path(ellipseIn: CGRect(
                        x: x0 - circleRadius,
                        y: y0 - circleRadius,
                        width: circleDiameter,
                        height: circleDiameter
                    )), with: qName == model.cur ? .color(.blue) : .color(.white))
                    
                    context.draw(Text(qName.isEmpty ? "ε" : qName).foregroundColor(.black).font(.system(size:fontSize)), at:CGPoint(x: x0, y: y0))
                    
                    var visited: [String:Int] = [:]

                    for (key, others) in adj {
                        for q in others {
                            if q == qName {
                                let loopRadius = circleRadius * 1.25
                                
                                var path = Path()
                                
                                path.addArc(
                                    center: CGPoint(x: x0, y: y0 - loopRadius),
                                    radius: loopRadius,
                                    startAngle: .degrees(180),
                                    endAngle: .degrees(0),
                                    clockwise: false
                                )
                                
                                context.stroke(path, with: .color(.green), lineWidth: 2)
                                
                                // seta (arrow)
                                let arrowAngle = 90 * Double.pi / 180.0
                                let ax = x0 + cos(0) * loopRadius
                                let ay = (y0 - loopRadius) + sin(0) * loopRadius
                                
                                var arrow = Path()
                                arrow.move(to: CGPoint(x: ax, y: ay))
                                arrow.addLine(to: CGPoint(
                                    x: ax - cos(arrowAngle + 0.4) * circleRadius * 0.6,
                                    y: ay - sin(arrowAngle + 0.4) * circleRadius * 0.6
                                ))
                                arrow.move(to: CGPoint(x: ax, y: ay))
                                arrow.addLine(to: CGPoint(
                                    x: ax - cos(arrowAngle - 0.4) * circleRadius * 0.6,
                                    y: ay - sin(arrowAngle - 0.4) * circleRadius * 0.6
                                ))
                                
                                context.stroke(arrow, with: .color(.green), lineWidth: 2)
                                
                                let count: Int = visited[q] ?? 0
                                let a = atan2(x0 - centerY, y0 - centerX - loopRadius * 2.4)
                                
                                // label
                                context.draw(
                                    Text(key.isEmpty ? "ε" : key).foregroundColor(.red).font(.system(size:fontSize)),
                                    at: CGPoint(x: x0, y: y0 - loopRadius * 2.4 + circleRadius * Double(count))
                                )
                                
                                visited[q, default: 0] += 1
                                continue
                            }
                            guard let p2 = nodes[q] else {continue}
                            let x1 = p2.x + circleRadius
                            let y1 = p2.y + circleRadius
                            
                            let xMid = (x1 * 3 + x0) / 4
                            let yMid = (y1 * 3 + y0) / 4
                            
                            let angle = atan2(y1 - y0, x1 - x0)
                            
                            var path = Path()
                            path.move(to: CGPoint(x: x0, y: y0))
                            path.addLine(to: CGPoint(x: xMid, y:yMid))
                            path.addLine(to: CGPoint(x: xMid - cos(angle + 0.4) * circleRadius, y: yMid - sin(angle + 0.4) * circleRadius))
                            path.addLine(to: CGPoint(x: xMid, y:yMid))
                            path.addLine(to: CGPoint(x: xMid - cos(angle - 0.4) * circleRadius, y: yMid - sin(angle - 0.4) * circleRadius))
                            path.addLine(to: CGPoint(x: xMid, y:yMid))
//                            path.addLine(to: CGPoint(x: x1 + circleRadius, y: y1 + circleRadius))
                            
                            context.stroke(path, with: .color(.green), lineWidth: 2)
                            let count: Int = visited[q] ?? 0
                            
                            let a = atan2(yMid - centerY, xMid - centerX)
                            
                            context.draw(Text(key.isEmpty ? "ε" : key).foregroundColor(.red).font(.system(size:fontSize)), at:CGPoint(x: xMid + cos(a) * circleRadius, y: yMid - circleRadius * Double(count) + sin(a) * circleRadius))
                            
                            visited[q, default: 0] += 1
                        }
                    }
                }
            }
            
            Slider(
                value: $model.speed,
                in: 0.01...0.999
            )
            
            HStack {
                Button("Reset"){
                    model.reset()
                }
                
                Button("Generate Entry"){
                    model.newEntry()
                }

                TextField("Entry", text: $text)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 200)

                Button("Change") {
                    model.getEntry(text)
                }
                
                Button("Build NFA from Regex") {
                    fromRegex(regex: text, model: model)
                }
            }
            
            HStack {
                Button("DFA") {
                    dfa(model)
                }

                Button("NFA") {
                    nfa(model)
                }
                
                Button("Convert (NFA -> DFA)") {
                    nfaToDfa(model)
                }
                
                Button("Discard States") {
                    discardStates(model)
                }
                
                Button("Simplify Names") {
                    renameAutomaton(model)
                }
            }
        }
        .padding()
    }
}

#Preview {
    AutomatonView()
        .frame(width: 800, height: 600)
}
