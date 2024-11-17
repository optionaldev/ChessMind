//
// The ChessMind project.
// Created by optionaldev on 09/11/2024.
// Copyright © 2024 optionaldev. All rights reserved.
// 

enum Piece: Character {
  
  case bishop = "b"
  case king   = "k"
  case knight = "n"
  case pawn   = "p"
  case queen  = "q"
  case rook   = "r"
  
  var fullName: String {
    switch self {
      case .bishop:
        return "bishop"
      case .king:
        return "king"
      case .knight:
        return "knight"
      case .pawn:
        return "pawn"
      case .queen:
        return "queen"
      case .rook:
        return "rook"
    }
  }
}
