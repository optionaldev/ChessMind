//
// The ChessMind project.
// Created by optionaldev on 21/12/2024.
// Copyright © 2024 optionaldev. All rights reserved.
// 

import Foundation

enum QuizHelper {
  
  static func getQuizes(forFile quizFile: String) -> [String: Quiz] {
    guard let unfilteredQuizes = JsonHelper.json([String: QuizDecodable].self, fromFile: quizFile) else {
      print("Failed to get json for quizFile \(quizFile)")
      return [:]
    }
    
    var filteredQuizes: [String: Quiz] = [:]
    
    unfilteredQuizes.forEach { key, value in
      if let opponentMoves = value.opponentMoves {
        if value.myMove != nil {
          print("An entry should not have both 'opponentMoves' and 'myMove'. Key: \(key)")
        }
        filteredQuizes[key] = .opponentMoves(opponentMoves)
      } else if let myMove = value.myMove {
        if value.opponentMoves != nil {
          print("An entry should not have both 'myMove' and 'opponentMoves'. Key: \(key)")
        }
        filteredQuizes[key] = .myMove(myMove, explanation: value.explanation ?? "")
      } else {
        print("An entry should have either opponentMoves or myMove. Key: \(key)")
      }
    }
    
    return filteredQuizes

  }
  
  static func getOpenings() -> [Opening] {
    guard let unfilteredOpenings = JsonHelper.json([Opening].self, fromFile: "openings.json") else {
      return []
    }
    
    var filteredOpenings: [Opening] = []
    
    unfilteredOpenings.forEach { opening in
      if opening.lines.isEmpty {
        print("Every opening should have at least one line. Opening: \(opening)")
      } else {
        filteredOpenings.append(opening)
        if opening.lines.count > 1 {
          if opening.lines.first(where: { $0.name == nil }) != nil {
            print("If an opening has multiple lines, they should all have a name. Opening: \(opening)")
          }
        }
      }
    }
    
    return filteredOpenings
  }
}
