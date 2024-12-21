//
// The ChessMind project.
// Created by optionaldev on 21/12/2024.
// Copyright © 2024 optionaldev. All rights reserved.
// 

struct QuizDecodable: Decodable {
  
  /// When available, it lists all moves that require a somewhat
  /// precise response. It usually won't list slow moves like "a6",
  /// "h6", to which you would generally simply respond with taking
  /// the center or playing aggressive.
  ///
  /// Format: "a6", "Nb5", "Bb5+", "Qxe7", etc
  let opponentMoves: [String]?
  
  /// Not necessarly the best move, but the move that the user
  /// chose for this particular position.
  let myMove: String?
  
  /// Explanation as to why the move is the chosen one in the current
  /// position. It _nil_ it usually means that it's simply a good
  /// developing move or simple improving move.
  let explanation: String?
}
