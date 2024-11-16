//
// The ChessMind project.
// Created by optionaldev on 17/11/2024.
// Copyright © 2024 optionaldev. All rights reserved.
//

enum HighlightType {
  
  case canMove
  case kingIsInCheck
  case previousMove(move: HighlightPreviousMoveType)
  case isSelected
}

enum HighlightPreviousMoveType {
  
  case from
  case to
}
