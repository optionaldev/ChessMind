//
// The ChessMind project.
// Created by optionaldev on 25/10/2024.
// Copyright © 2024 optionaldev. All rights reserved.
//

enum FenParser {
  
  /// Failure is represented by an empty arrow
  static func parse(fen: String) -> (allRows: [[SquareState]], boardSettings: BoardSettings) {
    let fenComponents = fen.components(separatedBy: " ")
    
    let fenBoard = fenComponents[0]
    let fenTurn = fenComponents[1]
    let fenCastlingRights = fenComponents[2]
//    let fenEnPassant = fenComponents[3]
    
    var currentRow: [SquareState] = []
    var currentRowIndex = 0
    var allRows: [[SquareState]] = []
    var remainingCharacters = ""
    
    for character in fenBoard {
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
          currentRow.append(.empty)
        }
      } else {
        var piece: Piece
        var side: Side
        switch character {
          case "r":
            piece = .rook
            side = .black
          case "R":
            piece = .rook
            side = .white
          case "b":
            piece = .bishop
            side = .black
          case "B":
            piece = .bishop
            side = .white
          case "n":
            piece = .knight
            side = .black
          case "N":
            piece = .knight
            side = .white
          case "q":
            piece = .queen
            side = .black
          case "Q":
            piece = .queen
            side = .white
          case "k":
            piece = .king
            side = .black
          case "K":
            piece = .king
            side = .white
          case "p":
            piece = .pawn
            side = .black
          case "P":
            piece = .pawn
            side = .white
          case "/":
            /// Forward slash ends the row
            currentRowIndex += 1
            allRows.append(currentRow)
            currentRow = []
            continue
          default:
            fatalError("Invalid fen: \"\(fen)\". Found invalid character \"\(character)\".")
        }
        let squareState = SquareState.occupied(piece: piece, side: side)
        
        currentRow.append(squareState)
      }
    }
    allRows.append(currentRow)
    
    allRows = allRows.reversed()
    
    let settings = BoardSettings(
      blackCastling: [fenCastlingRights.contains("k") ? .kingSide : nil,
                      fenCastlingRights.contains("q") ? .queenSide : nil].compactMap { $0 },
      whiteCastling: [fenCastlingRights.contains("K") ? .kingSide : nil,
                      fenCastlingRights.contains("Q") ? .queenSide : nil].compactMap { $0 },
      turn: fenTurn == "w" ? .white : .black)
    
    return (allRows, settings)
  }
}
