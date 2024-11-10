//
// The ChessMind project.
// Created by optionaldev on 25/10/2024.
// Copyright © 2024 optionaldev. All rights reserved.
//

enum SquareState: CustomStringConvertible {
  
  case empty
  case occupied(piece: Piece, side: Side)
  
  var imageName: String? {
    switch self {
      case .empty:
        return nil
      case .occupied(let piece, let side):
        return "\(piece.rawValue)_\(side.rawValue)"
    }
  }
  
  // MARK: CustomStringConvertible conformance
  
  var description: String {
    switch self {
      case .empty:
        return "\(SquareState.self) .empty"
      case .occupied(let piece, let side):
        return "\(SquareState.self) \(piece.rawValue) \(side)"
    }
  }
}
