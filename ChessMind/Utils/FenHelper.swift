//
// The ChessMind project.
// Created by optionaldev on 17/11/2024.
// Copyright © 2024 optionaldev. All rights reserved.
// 

enum FenHelper {
  
  static func pieceAndSide(forCharacter fenCharacter: Character) -> (Piece, Side)? {
    if let piece = Piece(rawValue: fenCharacter.lowercase) {
      return (piece, fenCharacter.isUppercase ? .white : .black)
    }
    return nil
  }
  
  static func fenCharacter(forPiece piece: Piece, side: Side) -> String {
    switch side {
      case .black:
        return piece.rawValue.string
      case .white:
        return piece.rawValue.uppercased()
    }
  }
}
