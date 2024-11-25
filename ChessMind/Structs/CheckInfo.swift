//
// The ChessMind project.
// Created by optionaldev on 24/11/2024.
// Copyright © 2024 optionaldev. All rights reserved.
// 

struct CheckInfo {
  
  let isInCheck: Bool
  let validPositionsForNonKingPieces: [Position]
  let oppositeSideOfCheck: Position
}
