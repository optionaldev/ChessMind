//
// The ChessMind project.
// Created by optionaldev on 25/10/2024.
// Copyright © 2024 optionaldev. All rights reserved.
// 

enum Quiz {
  
  /// A list of all moves that require a somewhat precise response.
  /// It usually won't list slow moves like "a6", "h6", to which you
  /// would generally simply respond with taking the center or
  /// playing aggressive.
  ///
  /// Format: "a6", "Nb5", "Bb5+", "Qxe7", etc
  case opponentMoves(_ moves: [String])
  
  /// Not necessarly the best move, but the move that the user
  /// chose for this particular position.
  case myMove(_ move: String, explanation: String)
}
