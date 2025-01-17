//
// The ChessMind project.
// Created by optionaldev on 10/11/2024.
// Copyright © 2024 optionaldev. All rights reserved.
// 

final class BoardSettings: CustomStringConvertible {
  
  var blackCastling: Set<CastlingSide> = []
  
  /// Use for knowing how many moves there were
  /// in the game for both sides.
  /// Increments with each move for black.
  /// Also known as fullmove.
  var blackMoves: Int = 0
  
  /// En passant represents the square a pawn
  /// passed while moving two squares. It's
  /// used to signal a possible target for
  /// adjacent pawns, although this is present
  /// even if there's no pawns that can
  /// capture it.
  var enPassant: Position? {
    didSet {
      if enPassant != oldValue {
        print("didSet enPassant = \(enPassant)")
      }
    }
  }
  
  /// There is a 50 move draw rule. If a player
  /// has not moved a pawn or captured a piece,
  /// this counter increases.
  /// Counter increases for both sides.
  /// Also known as half moves.
  var plies: Int = 0
  var turn: Turn = .white
  var whiteCastling: Set<CastlingSide> = []
  
  var kingIsInCheck: Bool = false
  
  var currentSideCastlingRights: Set<CastlingSide> {
    switch turn {
    case .black:
      return blackCastling
    case .white:
      return whiteCastling
    }
  }
  
  // MARK: Init
  
  init() {}
  
  init(blackCastling: Set<CastlingSide>, blackMoves: Int, enPassant: String?, plies: Int, turn: Turn, whiteCastling: Set<CastlingSide>) {
    self.blackCastling = blackCastling
    self.blackMoves = blackMoves
    
    if let enPassant = enPassant,
       enPassant != Constants.fenEmptyField
    {
      self.enPassant = Position(notation: enPassant)
    } else {
      self.enPassant = nil
    }
    self.plies = plies
    self.turn = turn
    self.whiteCastling = whiteCastling
  }
  
  // MARK: CustomStringConvertible conformance
  
  var description: String {
    return "\(Self.self): turn = \(turn) | whiteCastling = \(whiteCastling) | blackCastling = \(blackCastling) | enPassant = \(String(describing: enPassant)) | plies = \(plies) | blackMoves = \(blackMoves)"
  }
}
