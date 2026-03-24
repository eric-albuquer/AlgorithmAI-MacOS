import SwiftUI

struct ContentView: View {
    
    enum Screen: Hashable {
        case arraysearch
        case sorting
        case pathfinding
        case tsalesman
        case sudoku
        case linearsolver
        case wordsearch
        case automaton
        case render
    }
    
    @State private var screen: Screen? = nil
    
    var body: some View {
        NavigationStack {
            
            ZStack {
                
                LinearGradient(
                    colors: [.black, .blue.opacity(0.6)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 40) {
                        
                        VStack(spacing: 10) {
                            
                            Text("Algorithm Visualizer")
                                .font(.system(size: 40, weight: .bold))
                                .foregroundStyle(.white)
                            
                            Text("Explore classic algorithms visually")
                                .foregroundStyle(.white.opacity(0.8))
                        }
                        
                        VStack(spacing: 20) {
                            
                            MenuButton(
                                title: "Array Search",
                                icon: "rectangle.grid.1x2"
                            ) {
                                screen = .arraysearch
                            }
                            
                            MenuButton(
                                title: "Sorting",
                                icon: "arrow.up.arrow.down"
                            ) {
                                screen = .sorting
                            }
                            
                            MenuButton(
                                title: "Pathfinding",
                                icon: "map"
                            ) {
                                screen = .pathfinding
                            }
                            
                            MenuButton(
                                title: "Traveling Salesman",
                                icon:"point.topleft.down.curvedto.point.bottomright.up"
                            ) {
                                screen = .tsalesman
                            }
                            
                            MenuButton(
                                title: "Sudoku Solver",
                                icon: "square.grid.3x3"
                            ) {
                                screen = .sudoku
                            }
                            
                            MenuButton(
                                title: "Linear Solver",
                                icon: "function"
                            ) {
                                screen = .linearsolver
                            }
                            
                            MenuButton(
                                title: "Word Search",
                                icon: "text.magnifyingglass"
                            ) {
                                screen = .wordsearch
                            }
                            
                            MenuButton(
                                title: "Automaton",
                                icon: "point.3.connected.trianglepath.dotted"
                            ) {
                                screen = .automaton
                            }
                            
                            MenuButton(
                                title: "3D Render",
                                icon: "cube.fill"
                            ) {
                                screen = .render
                            }
                        }
                    }
                }
            }
            .navigationDestination(item: $screen) { screen in
                
                switch screen {
                case .arraysearch:
                    ArraySearchView()
                    
                case .sorting:
                    SortView()
                    
                case .pathfinding:
                    PathfindingView()
                    
                case .tsalesman:
                    TSalesmanView()
                    
                case .sudoku:
                    SudokuView()
                    
                case .linearsolver:
                    LinearSolverView()
                    
                case .wordsearch:
                    WordSearchView()
                    
                case .automaton:
                    AutomatonView()
                    
                case .render:
                    RenderView()
                }
            }
        }
    }
}

struct MenuButton: View {
    
    let title: String
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            
            HStack(spacing: 15) {
                
                Image(systemName: icon)
                    .font(.title2)
                
                Text(title)
                    .font(.title3.bold())
            }
            .foregroundStyle(.white)
            .frame(width: 260, height: 60)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(.blue.opacity(0.8))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(.white.opacity(0.2))
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ContentView()
}
