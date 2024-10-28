//
// The ChessMind project.
// Created by optionaldev on 25/10/2024.
// Copyright © 2024 optionaldev. All rights reserved.
// 

enum FenParser {
  
  /// Failure is represented by an empty arrow
  static func parse(fen: String) -> (allRows: [[Square]], canCastle: Bool) {
    var currentRow: [Square] = []
    var currentRowIndex = 0
    var allRows: [[Square]] = []
    var remainingCharacters = ""
    
    for character in fen {
      if allRows.count == Constants.boardLength &&
          allRows.last?.count == Constants.boardLength
      {
        /// We have finished parsing the squares
        /// Extra information remaining that we parse
        /// after the for loop.
        remainingCharacters.append(character)
        continue
      }
      
      if let number = Int(String(character)) {
        /// FEN notation uses numbers to signify
        /// how many empty squares are next to
        /// each other to save space
        for _ in 0..<number {
          currentRow.append(Square.empty)
        }
      } else {
        let square: Square
        switch character {
          case "r":
            square = .rook(white: false)
          case "R":
            square = .rook(white: true)
          case "b":
            square = .bishop(white: false)
          case "B":
            square = .bishop(white: true)
          case "n":
            square = .knight(white: false)
          case "N":
            square = .knight(white: true)
          case "q":
            square = .queen(white: false)
          case "Q":
            square = .queen(white: true)
          case "k":
            square = .king(white: false)
          case "K":
            square = .king(white: true)
          case "p":
            square = .pawn(white: false)
          case "P":
            square = .pawn(white: true)
          default:
            print("Invalid fen: \"\(fen)\". Found invalid character \"\(character)\".")
            return ([], false)
        }
        currentRow.append(square)
      }
      /// Once we have enough characters to fill
      /// a row, we move onto the next row
      if currentRow.count == Constants.boardLength {
        currentRowIndex += 1
        allRows.append(currentRow)
        currentRow = []
      }
    }
    /// The remaining characters from the fen
    
    var canCastle = true
    
    return (allRows, canCastle)
  }
}
