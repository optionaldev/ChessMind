//
// The ChessMind project.
// Created by optionaldev on 21/12/2024.
// Copyright © 2024 optionaldev. All rights reserved.
// 

import Foundation

enum QuizParser {
  
  static func getDatabase() -> QuizDatabase? {
    guard let url = Bundle.main.url(forResource: "temp", withExtension: "json") else {
      print("Failed to find temp.json file.")
      return nil
    }
    
    let jsonData: Data
    do {
      jsonData = try Data(contentsOf: url)
    } catch {
      print("Failed to get data from url = \(url) error = \(error)")
      return nil
    }
    
    let quizDatabaseDecodable: QuizDatabaseDecodable
    do {
      quizDatabaseDecodable = try JSONDecoder().decode(QuizDatabaseDecodable.self,
                                                       from: jsonData)
    } catch {
      print("Decoding temp.json failed \(error)")
      return nil
    }
    
    var openings: [Opening] = []
    quizDatabaseDecodable.openings.forEach { opening in
      if opening.lines.isEmpty {
        print("Every opening should have at least one line. Opening: \(opening)")
      } else {
        openings.append(opening)
        
        if opening.lines.count > 1 {
          if opening.lines.first(where: { $0.name == nil }) != nil {
            print("If an opening has multiple lines, they should all have a name. Opening: \(opening)")
          }
        }
      }
    }
    
    var quizes: [String: Quiz] = [:]
    
    quizDatabaseDecodable.quizes.forEach { key, value in
      if let opponentMoves = value.opponentMoves {
        if value.myMove != nil {
          print("An entry should not have both opponentMoves and myMove. Key: \(key)")
        }
        quizes[key] = .opponentMoves(opponentMoves)
      } else if let myMove = value.myMove {
        if value.opponentMoves != nil {
          print("An entry should not have both myMove and opponentMoves. Key: \(key)")
        }
        quizes[key] = .myMove(myMove, explanation: value.explanation ?? "")
      } else {
        print("An entry should have either opponentMoves or myMove. Key: \(key)")
      }
    }
    
    return QuizDatabase(openings: openings,
                        quizes: quizes)
  }
}
