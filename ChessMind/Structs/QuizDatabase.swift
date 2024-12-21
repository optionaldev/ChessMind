//
// The ChessMind project.
// Created by optionaldev on 21/12/2024.
// Copyright © 2024 optionaldev. All rights reserved.
// 

struct QuizDatabase {
  
  /// A dictionary where key is the opening name and
  /// the value is the starting position (FEN)
  let openings: [Opening]
  
  /// A dictionary where the key is a position (FEN)
  /// and the value contains information about the
  /// next move (either possible opponent moves or
  /// the move that I should make)
  let quizes: [String: Quiz]
}
