//
// The ChessMind project.
// Created by optionaldev on 25/10/2024.
// Copyright © 2024 optionaldev. All rights reserved.
// 

enum Square {
  
  case bishop(white: Bool)
  case empty
  case knight(white: Bool)
  case king(white: Bool)
  case pawn(white: Bool)
  case queen(white: Bool)
  case rook(white: Bool)
  
  var imageName: String {
    switch self {
      case .bishop(let white):
        return white ? "bishop_white" : "bishop_black"
      case .empty:
        return ""
      case .knight(let white):
        return white ? "knight_white" : "knight_black"
      case .king(let white):
        return white ? "king_white" : "king_black"
      case .pawn(let white):
        return white ? "pawn_white" : "pawn_black"
      case .queen(let white):
        return white ? "queen_white" : "queen_black"
      case .rook(let white):
        return white ? "rook_white" : "rook_black"
    }
  }
}
