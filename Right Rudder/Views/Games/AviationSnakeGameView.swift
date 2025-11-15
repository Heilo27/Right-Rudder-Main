//
//  AviationSnakeGameView.swift
//  Right Rudder
//
//  Aviation-themed Snake game with airplane, banner tail, and clouds
//

import Combine
import SwiftUI

// MARK: - AviationSnakeGameView

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

      Text(
        "Airplane will start moving in \(game.countdown) second\(game.countdown == 1 ? "" : "s")"
      )
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
