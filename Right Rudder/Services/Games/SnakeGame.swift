//
//  SnakeGame.swift
//  Right Rudder
//
//  Aviation-themed Snake game model
//

import Combine
import Foundation

// MARK: - SnakeGame

class SnakeGame: ObservableObject {
  // MARK: - Published Properties

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

  // MARK: - Properties

  private var currentDirection: Direction = .right
  private var gameTimer: Timer?
  private var segmentDirections: [Direction] = []  // Track direction for each segment

  // MARK: - Initialization

  init(columns: Int, rows: Int) {
    self.columns = columns
    self.rows = rows
    reset()
  }

  // MARK: - Methods

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
    currentDirection = .right  // Reset direction to default
    food = []  // Reset food array

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
      // Silently return if game is over or not playing - no need to spam debug
      return
    }

    print(
      "🎮 Moving airplane from (\(currentHead.x), \(currentHead.y)) in direction \(currentDirection)"
    )

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
    // Use same boundary as clouds - three positions higher from bottom
    let maxY = rows - 3  // Three positions higher from bottom
    if newHead.x < 0 || newHead.x >= columns || newHead.y < 0 || newHead.y >= maxY {
      print("🎮 Game Over: Airplane hit wall at (\(newHead.x), \(newHead.y))")
      isGameOver = true
      stopGame()  // Stop the timer when game ends
      return
    }

    // Check self collision
    if banner.contains(newHead) {
      isGameOver = true
      stopGame()  // Stop the timer when game ends
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
    print(
      "🎮 Generating initial clouds - Banner length: \(banner.count), Head: \(head?.description ?? "nil")"
    )
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
    let margin = 4  // Keep clouds at least 4 cells away from edges
    let minX = max(0, margin)
    let maxX = max(minX, columns - margin - 1)
    let minY = max(0, margin)
    let maxY = max(minY, rows - margin - 3)  // Three positions higher from bottom

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
      return .right  // Default direction if index is out of bounds
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

