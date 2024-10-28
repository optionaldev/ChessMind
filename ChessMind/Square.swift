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
        return white ? "" : ""
      case .empty:
        return ""
      case .knight(let white):
        return white ? "" : ""
      case .king(let white):
        return white ? "" : ""
      case .pawn(let white):
        return white ? "" : ""
      case .queen(let white):
        return white ? "" : ""
      case .rook(let white):
        return white ? "" : ""
    }
  }
}
