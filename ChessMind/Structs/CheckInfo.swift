//
// The ChessMind project.
// Created by optionaldev on 24/11/2024.
// Copyright © 2024 optionaldev. All rights reserved.
// 

struct CheckInfo {
  
  let checkState: CheckState
  let validPositionsForNonKingPieces: [Position]
  let oppositeSideOfCheck: Position?
  
  var isInCheck: Bool {
    switch checkState {
      case .notInCheck:
        return false
      case .checkedByOnePiece, .checkedByKnight, .checkedByTwoPieces:
        return true
    }
  }
}
