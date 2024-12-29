//
// The ChessMind project.
// Created by optionaldev on 22/11/2024.
// Copyright © 2024 optionaldev. All rights reserved.
// 

/// A enum for describing a king's current state.
enum CheckState {

  /// The king is not in check.
  case notInCheck
  
  /// The king is in check from one enemy piece. In this scenario,
  /// the king can get out of the check in 3 ways: moving to an
  /// unattacked square, capturing the checking piece (if close
  /// enough) or blocking with an own piece (if there is at least one
  /// square between the piece attacking the king and the king)
  case checkedByOnePiece(atPosition: Position, fromDirection: Direction)
  
  /// The king is in check by the knight.
  /// In this case, the king cannot capture the attacking piece, but
  /// he can get out of check by moving or if another piece
  /// captures the attacking knight.
  case checkedByKnight(atPosition: Position)
  
  /// The king is in a check by two pieces.
  /// In this scenario, the king can get out of
  /// the check in 2 ways: moving to an unattacked
  /// square or capturing the checking piece (if
  /// close enough).
  case checkedByTwoPieces
}
