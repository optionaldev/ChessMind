//
// The ChessMind project.
// Created by optionaldev on 21/12/2024.
// Copyright © 2024 optionaldev. All rights reserved.
// 

struct QuizDatabaseDecodable: Decodable {
  
  /// An array of openings, containing opening name, starting position
  /// and maybe a logo in the future.
  let openings: [Opening]
  
  /// A dictionary where the key is a position (FEN) and the value
  /// contains information about the next move (either possible
  /// opponent moves or the move that the user should make in
  /// respose to the given position)
  let quizes: [String: QuizDecodable]
}
