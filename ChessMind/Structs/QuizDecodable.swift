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
  /// Format: "a6", "Nb5", "Bb5+", "Qxe7", "Nc7#" etc
  let opponentMoves: [String]?
  
  let myMoves: [MyMove]?
}

struct MyMove: Decodable {
    
    /// Move chosen to analyze and include.
    let notation: String
    
    /// Explanation as to why the move is the chosen one in the current
    /// position.
    /// The only time we don't have an explanation is when it's a
    /// checkmate move.
    let explanation: String?
}
