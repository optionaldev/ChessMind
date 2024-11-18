//
// The ChessMind project.
// Created by optionaldev on 10/11/2024.
// Copyright © 2024 optionaldev. All rights reserved.
// 

enum Direction: CaseIterable {
  
  case bottomLeft
  case bottomRight
  case down
  case left
  case right
  case topLeft
  case topRight
  case up
    
  static func directions(forPinnedDirection pinnedDirection: Direction) -> [Direction] {
    switch pinnedDirection {
    case .bottomLeft, .topRight:
      return [.bottomLeft, .topRight]
    case .bottomRight, .topLeft:
      return [.bottomRight, .topLeft]
    case .down, .up:
      return [.down, .up]
    case .left, .right:
      return [.left, .right]
    }
  }
  
  var opposite: Direction {
    switch self {
    case .bottomLeft:
      return .topRight
    case .bottomRight:
      return .topLeft
    case .down:
      return .up
    case .left:
      return .right
    case .right:
      return .left
    case .topLeft:
      return .bottomRight
    case .topRight:
      return .bottomLeft
    case .up:
      return .down
    }
  }
  
  var isDiagonal: Bool {
    switch self {
    case .bottomLeft, .bottomRight, .topLeft, .topRight:
      return true
    case .down, .left, .right, .up:
      return false
    }
  }
}
