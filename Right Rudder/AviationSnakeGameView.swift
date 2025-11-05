//
//  AviationSnakeGameView.swift
//  Right Rudder
//
//  Aviation-themed Snake game with airplane, banner tail, and clouds
//

import SwiftUI
import Combine

// MARK: - Supporting Types

public enum Direction {
    case up, down, left, right
}

public struct Point: Equatable {
    public var x: Int
    public var y: Int
    
    public init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }
    
    public var description: String {
        return "(\(x), \(y))"
    }
}

public struct AirplaneView: View {
    public let direction: Direction
    
    public init(direction: Direction) {
        self.direction = direction
    }
    
    public var body: some View {
        Image(systemName: "airplane")
            .foregroundColor(.blue)
            .font(.system(size: 16, weight: .bold))
            .rotationEffect(.degrees(rotationAngle))
    }
    
    private var rotationAngle: Double {
        switch direction {
        case .up: return -90
        case .down: return 90
        case .left: return 180
        case .right: return 0
        }
    }
}

public struct CloudView: View {
    public var body: some View {
        ZStack {
            Circle()
                .fill(Color.white.opacity(0.8))
                .frame(width: 12, height: 12)
                .offset(x: -3, y: 0)
            
            Circle()
                .fill(Color.white.opacity(0.8))
                .frame(width: 10, height: 10)
                .offset(x: 3, y: 0)
            
            Circle()
                .fill(Color.white.opacity(0.8))
                .frame(width: 8, height: 8)
                .offset(x: 0, y: 2)
        }
    }
}

public struct BannerSegmentView: View {
    public let position: Point
    public let index: Int
    public let total: Int
    public let isLast: Bool
    public let direction: Direction
    
    public init(position: Point, index: Int, total: Int, isLast: Bool, direction: Direction) {
        self.position = position
        self.index = index
        self.total = total
        self.isLast = isLast
        self.direction = direction
    }
    
    public var body: some View {
        ZStack {
            // Banner segment - orient based on direction
            Rectangle()
                .fill(bannerColor)
                .frame(
                    width: (direction == .up || direction == .down) ? 3 : 12,
                    height: (direction == .up || direction == .down) ? 12 : 3
                )
                .cornerRadius(1)
            
            // Text on banner (if long enough and showing message)
            if total >= 22 {
                let textStartIndex = max(0, total - 22)
                if index >= textStartIndex {
                    let textIndex = index - textStartIndex
                    let messageWithoutSpaces = bannerText.replacingOccurrences(of: " ", with: "")
                    let bannerCharacters = Array(messageWithoutSpaces)
                    
                    // Map text characters to banner segments (stretch text across available segments)
                    let textLength = bannerCharacters.count
                    let availableSegments = total - textStartIndex
                    let segmentRatio = Double(textLength) / Double(availableSegments)
                    let charIndex = Int(Double(textIndex) * segmentRatio)
                    
                           if charIndex < textLength {
                               Text(String(bannerCharacters[charIndex]))
                                   .font(.system(size: 7, weight: .bold))
                                   .foregroundColor(.white)
                                   .frame(
                                       width: (direction == .up || direction == .down) ? 3 : 12,
                                       height: (direction == .up || direction == .down) ? 12 : 3
                                   )
                           }
                }
            }
        }
    }
    
    private var bannerColor: Color {
        // Make banner segments slightly different shades
        let ratio = Double(index) / Double(max(total, 1))
        return Color.blue.opacity(0.7 - ratio * 0.3)
    }
    
    private var bannerText = "Thank you for your support"
}

// MARK: - Game Model

class SnakeGame: ObservableObject {
    let columns: Int
    let rows: Int
    @Published var head: Point?
    @Published var banner: [Point] = []
    @Published var food: [Point] = []
    @Published var score: Int = 0
    @Published var isGameOver: Bool = false
    @Published var countdown: Int = 3
    @Published var isCountingDown: Bool = true
    @Published var isPlaying: Bool = false
    
    private var currentDirection: Direction = .right
    private var gameTimer: Timer?
    private var segmentDirections: [Direction] = [] // Track direction for each segment
    
    init(columns: Int, rows: Int) {
        self.columns = columns
        self.rows = rows
        reset()
    }
    
    func reset() {
        // Stop any existing timer first
        stopGame()
        
        let startX = columns / 2
        let startY = rows / 2
        head = Point(x: startX, y: startY)
        banner = []
        segmentDirections = []
        score = 0
        isGameOver = false
        countdown = 3
        isCountingDown = true
        isPlaying = false
        currentDirection = .right // Reset direction to default
        food = [] // Reset food array
        
        print("🎮 Game reset - Head: (\(startX), \(startY)), Direction: \(currentDirection)")
        print("🎮 Grid size: \(columns)x\(rows)")
        
        generateInitialFood()
    }
    
    func startCountdown() {
        isCountingDown = true
        countdown = 3
        
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            DispatchQueue.main.async {
                self.countdown -= 1
                if self.countdown <= 0 {
                    timer.invalidate()
                    self.isCountingDown = false
                    self.isPlaying = true
                    self.startGameTimer()
                }
            }
        }
    }
    
    private func startGameTimer() {
        gameTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            DispatchQueue.main.async {
                self.executeMove()
            }
        }
    }
    
    func stopGame() {
        gameTimer?.invalidate()
        gameTimer = nil
        isPlaying = false
    }
    
    func move(direction: Direction) {
        // This function is no longer used - direction changes are handled by changeDirection()
        guard !isGameOver, !isCountingDown, isPlaying, head != nil else { return }
        
        // Update direction for next move
        switch (currentDirection, direction) {
        case (.up, .down), (.down, .up), (.left, .right), (.right, .left):
            // Ignore reverse direction
            break
        default:
            currentDirection = direction
        }
    }
    
    func executeMove() {
        guard !isGameOver, !isCountingDown, isPlaying, let currentHead = head else { 
            print("🎮 executeMove blocked: isGameOver=\(isGameOver), isCountingDown=\(isCountingDown), isPlaying=\(isPlaying), head=\(head != nil)")
            return 
        }
        
        print("🎮 Moving airplane from (\(currentHead.x), \(currentHead.y)) in direction \(currentDirection)")
        
        // Calculate new head position
        var newHead = currentHead
        switch currentDirection {
        case .up:
            newHead.y -= 1
        case .down:
            newHead.y += 1
        case .left:
            newHead.x -= 1
        case .right:
            newHead.x += 1
        }
        
        // Check wall collision (airplane hits edge of playable area)
        // Use same boundary as clouds - one position higher from bottom
        let maxY = rows - 2 // One position higher from bottom
        if newHead.x < 0 || newHead.x >= columns || newHead.y < 0 || newHead.y >= maxY {
            print("🎮 Game Over: Airplane hit wall at (\(newHead.x), \(newHead.y))")
            isGameOver = true
            return
        }
        
        // Check self collision
        if banner.contains(newHead) {
            isGameOver = true
            return
        }
        
        // Check food collision
        if let foodIndex = food.firstIndex(of: newHead) {
            print("🎮 Cloud eaten! Score: \(score + 1)")
            score += 1
            // Remove the eaten cloud
            food.remove(at: foodIndex)
            // Don't remove tail, so banner grows
            ensureFoodCount()
        } else if !banner.isEmpty {
            // Remove last segment if not eating
            banner.removeFirst()
            segmentDirections.removeFirst()
        }
        
        // Add current head to banner trail
        banner.append(currentHead)
        segmentDirections.append(currentDirection)
        
        // Update head
        head = newHead
    }
    
    func changeDirection(_ direction: Direction) {
        guard isPlaying else { 
            print("🎮 Direction change ignored - game not playing")
            return 
        }
        
        // Prevent reverse direction
        switch (currentDirection, direction) {
        case (.up, .down), (.down, .up), (.left, .right), (.right, .left):
            // Ignore reverse direction
            print("🎮 Direction change ignored - reverse direction")
            break
        default:
            print("🎮 Direction changed from \(currentDirection) to \(direction)")
            currentDirection = direction
        }
    }
    
    private func generateInitialFood() {
        print("🎮 Generating initial clouds - Banner length: \(banner.count), Head: \(head?.description ?? "nil")")
        print("🎮 Grid size: \(columns)x\(rows)")
        
        food = []
        let targetCount = 3
        
        for _ in 0..<targetCount {
            generateSingleCloud()
        }
        
        print("🎮 Generated \(food.count) clouds: \(food.map { $0.description })")
    }
    
    private func ensureFoodCount() {
        let targetCount = 3
        let currentCount = food.count
        
        print("🎮 Ensuring food count - Current: \(currentCount), Target: \(targetCount)")
        
        for _ in currentCount..<targetCount {
            generateSingleCloud()
        }
        
        print("🎮 Now have \(food.count) clouds: \(food.map { $0.description })")
    }
    
    private func generateSingleCloud() {
        var attempts = 0
        var newCloud: Point?
        
        // Define safe playable area (well within the visible bounds)
        let margin = 4 // Keep clouds at least 4 cells away from edges
        let minX = max(0, margin)
        let maxX = max(minX, columns - margin - 1)
        let minY = max(0, margin)
        let maxY = max(minY, rows - margin - 2) // One position higher from bottom
        
        print("🎮 Cloud bounds: X(\(minX)-\(maxX)), Y(\(minY)-\(maxY))")
        
        // Check if we have a valid playable area
        if minX > maxX || minY > maxY || columns < 10 || rows < 10 {
            print("⚠️ ERROR: No valid playable area for clouds! Grid: \(columns)x\(rows)")
            return
        }
        
        repeat {
            newCloud = Point(
                x: Int.random(in: minX...maxX),
                y: Int.random(in: minY...maxY)
            )
            attempts += 1
        } while (newCloud == head || food.contains(newCloud ?? Point(x: -1, y: -1))) && attempts < 100
        
        if let cloud = newCloud {
            food.append(cloud)
            print("🎮 Added cloud at \(cloud.description) after \(attempts) attempts")
        } else {
            print("⚠️ Failed to generate cloud after \(attempts) attempts")
            // Force place a cloud even if it overlaps
            let forcedCloud = Point(
                x: Int.random(in: minX...maxX),
                y: Int.random(in: minY...maxY)
            )
            food.append(forcedCloud)
            print("🎮 Forced cloud placement at \(forcedCloud.description)")
        }
    }
    
    func getDirectionForSegment(at index: Int) -> Direction {
        guard index < segmentDirections.count else {
            return .right // Default direction if index is out of bounds
        }
        return segmentDirections[index]
    }
    
    func updateGridSize(columns: Int, rows: Int) {
        // Update grid size and regenerate food if needed
        if columns != self.columns || rows != self.rows {
            print("🎮 Updating grid size from \(self.columns)x\(self.rows) to \(columns)x\(rows)")
            
            // Clear existing food
            food = []
            
            // Update grid dimensions (this would require making columns/rows mutable)
            // For now, we'll regenerate food with the new constraints
            generateInitialFood()
        }
    }
}

// MARK: - Main View

public struct AviationSnakeGameView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var game: SnakeGame
    @State private var direction: Direction = .right
    @State private var showingMessage = false
    @State private var gameBoardSize: CGSize = .zero
    
    private let gridSize: CGFloat = 20
    private let cellSize: CGFloat = 15
    
    init() {
        // Start with a reasonable default grid size
        let cols = 20
        let rows = 30
        _game = StateObject(wrappedValue: SnakeGame(columns: cols, rows: rows))
    }
    
    public var body: some View {
        ZStack {
            backgroundView
            mainGameView
        }
        .navigationTitle("Aviation Snake")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            game.startCountdown()
        }
        .onDisappear {
            game.stopGame()
        }
    }
    
    private var backgroundView: some View {
        LinearGradient(
            colors: [Color.blue.opacity(0.3), Color.cyan.opacity(0.2)],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
    
    private var mainGameView: some View {
        VStack(spacing: 10) {
            scoreHeaderView
            
            if game.isCountingDown {
                countdownView
            } else {
                gameBoardView
                directionButtonsView
            }
        }
    }
    
    private var countdownView: some View {
        VStack(spacing: 20) {
            Text("Get Ready!")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.blue)
            
            Text("\(game.countdown)")
                .font(.system(size: 80, weight: .bold))
                .foregroundColor(.red)
                .scaleEffect(game.countdown > 0 ? 1.2 : 0.8)
                .animation(.easeInOut(duration: 0.5), value: game.countdown)
            
            Text("Airplane will start moving in \(game.countdown) second\(game.countdown == 1 ? "" : "s")")
                .font(.headline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var scoreHeaderView: some View {
        HStack {
            Text("Clouds: \(game.score)")
                .font(.headline)
                .foregroundColor(.primary)
            
            Spacer()
            
            if game.score >= 22 {
                Text("Thank you for your support!")
                    .font(.caption)
                    .foregroundColor(.green)
                    .bold()
            }
            
            HStack(spacing: 10) {
                Button("Reset") {
                    game.reset()
                    game.startCountdown()
                    direction = .right
                }
                .buttonStyle(.bordered)
                
                Button("Done") {
                    game.stopGame()
                    dismiss()
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
    }
    
    private var gameBoardView: some View {
        GeometryReader { geometry in
            ZStack {
                bannerTrailView
                airplaneHeadView
                cloudFoodView
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .background(Color.white.opacity(0.1))
            .cornerRadius(10)
            .onAppear {
                updateGameGridSize(geometry: geometry)
            }
            .onChange(of: geometry.size) { _, _ in
                updateGameGridSize(geometry: geometry)
            }
        }
        .padding()
    }
    
    private func updateGameGridSize(geometry: GeometryProxy) {
        let newSize = geometry.size
        if newSize != gameBoardSize {
            gameBoardSize = newSize
            
            let cols = Int(newSize.width / cellSize)
            let rows = Int(newSize.height / cellSize)
            
            print("🎮 Game board size: \(newSize.width)x\(newSize.height)")
            print("🎮 New grid: \(cols)x\(rows)")
            
            // Update the game's grid size
            game.updateGridSize(columns: cols, rows: rows)
        }
    }
    
    private var bannerTrailView: some View {
        ForEach(Array(game.banner.enumerated()), id: \.offset) { index, segment in
            BannerSegmentView(
                position: segment,
                index: index,
                total: game.banner.count,
                isLast: index == game.banner.count - 1,
                direction: game.getDirectionForSegment(at: index)
            )
            .position(
                x: CGFloat(segment.x) * cellSize + cellSize / 2,
                y: CGFloat(segment.y) * cellSize + cellSize / 2
            )
        }
    }
    
    private var airplaneHeadView: some View {
        Group {
            if let head = game.head {
                AirplaneView(direction: direction)
                    .frame(width: cellSize + 4, height: cellSize + 4)
                    .position(
                        x: CGFloat(head.x) * cellSize + cellSize / 2,
                        y: CGFloat(head.y) * cellSize + cellSize / 2
                    )
            }
        }
    }
    
    private var cloudFoodView: some View {
        ForEach(Array(game.food.enumerated()), id: \.offset) { index, cloud in
            CloudView()
                .frame(width: cellSize, height: cellSize)
                .position(
                    x: CGFloat(cloud.x) * cellSize + cellSize / 2,
                    y: CGFloat(cloud.y) * cellSize + cellSize / 2
                )
        }
    }
    
    
    private var directionButtonsView: some View {
        VStack(spacing: 8) {
            upButton
            horizontalButtons
            downButton
        }
        .padding(.bottom)
    }
    
    private var upButton: some View {
        Button(action: { 
            direction = .up
            game.changeDirection(direction)
        }) {
            Image(systemName: "arrow.up")
                .font(.title2)
                .frame(width: 50, height: 50)
        }
        .buttonStyle(.bordered)
    }
    
    private var horizontalButtons: some View {
        HStack(spacing: 50) {
            Button(action: { 
                direction = .left
                game.changeDirection(direction)
            }) {
                Image(systemName: "arrow.left")
                    .font(.title2)
                    .frame(width: 50, height: 50)
            }
            .buttonStyle(.bordered)
            
            Button(action: { 
                direction = .right
                game.changeDirection(direction)
            }) {
                Image(systemName: "arrow.right")
                    .font(.title2)
                    .frame(width: 50, height: 50)
            }
            .buttonStyle(.bordered)
        }
    }
    
    private var downButton: some View {
        Button(action: { 
            direction = .down
            game.changeDirection(direction)
        }) {
            Image(systemName: "arrow.down")
                .font(.title2)
                .frame(width: 50, height: 50)
        }
        .buttonStyle(.bordered)
    }
    
    // These functions are no longer needed as the game manages its own timer
}


