//
// The ChessMind project.
// Created by optionaldev on 25/10/2024.
// Copyright © 2024 optionaldev. All rights reserved.
//

private extension Constants {
  
  static let fenSeparator = " "
}

enum FenParser {
  
  /// Failure is represented by an empty arrow
  static func parse(fen: String) -> (allRows: [[SquareState]], boardSettings: BoardSettings) {
    let fenComponents = fen.components(separatedBy: Constants.fenSeparator)
    
    let fenBoard = fenComponents[0]
    let fenTurn = fenComponents[1]
    let fenCastlingRights = fenComponents[2]
    let fenEnPassant = fenComponents[3]
    
    guard let fenPlies = Int(fenComponents[4]) else {
      fatalError("Received something that isn't a digit for number of plies.")
    }
    guard let fenBlackMoves = Int(fenComponents[5]) else {
      fatalError("Received something that isn't a digit for number of black moves.")
    }
    
    var currentRow: [SquareState] = []
    var currentRowIndex = 0
    var board: [[SquareState]] = []
    var remainingCharacters = ""
    
    for character in fenBoard {
      if board.count == Constants.boardLength &&
          board.last?.count == Constants.boardLength
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
        if let (piece, side) = FenHelper.pieceAndSide(forCharacter: character) {
          currentRow.append(SquareState.occupied(piece: piece, side: side))
        } else if character ==  "/" {
          /// Forward slash ends the row
          currentRowIndex += 1
          board.append(currentRow)
          currentRow = []
          continue
        } else {
            fatalError("Invalid fen: \"\(fen)\". Found invalid character \"\(character)\".")
        }
      }
    }
    board.append(currentRow)
    
    board = board.reversed()
    
    var blackCastling: Set<CastlingSide> = []
    if fenCastlingRights.contains("k") {
      blackCastling.insert(.kingSide)
    }
    if fenCastlingRights.contains("q") {
      blackCastling.insert(.queenSide)
    }
    
    var whiteCastling: Set<CastlingSide> = []
    if fenCastlingRights.contains("K") {
      whiteCastling.insert(.kingSide)
    }
    if fenCastlingRights.contains("Q") {
      whiteCastling.insert(.queenSide)
    }
    
    let settings = BoardSettings(
      blackCastling: blackCastling,
      blackMoves: fenBlackMoves,
      enPassant: fenEnPassant,
      plies: fenPlies,
      turn: fenTurn == "w" ? .white : .black,
      whiteCastling: whiteCastling)
    
    return (board, settings)
  }
  
  static func fen(forBoard board: [[SquareState]], settings: BoardSettings) -> String {
    var result = ""
    var currentEmptySquares = 0
    
    for row in board {
      for square in row {
        switch square {
          case .empty:
            currentEmptySquares += 1
          case .occupied(let piece, let side):
            if currentEmptySquares != 0 {
              result += "\(currentEmptySquares)"
              currentEmptySquares = 0
            }
            
            result += FenHelper.fenCharacter(forPiece: piece, side: side)
        }
      }
      
      if currentEmptySquares != 0 {
        result += "\(currentEmptySquares)"
        currentEmptySquares = 0
      }
      result += "/"
    }
    /// We remove the last "/" since it's more complicated to check
    /// if we're on the last row
    result.removeLast()
    
    if currentEmptySquares != 0 {
      result += "\(currentEmptySquares)"
    }
    
    result += Constants.fenSeparator
    
    switch settings.turn {
      case .white:
        result += "w"
      case .black:
        result += "b"
    }
    
    result += Constants.fenSeparator
    
    if settings.blackCastling.isEmpty && settings.whiteCastling.isEmpty {
      result += Constants.fenEmptyField
    } else {
      if settings.whiteCastling.contains(.kingSide) {
        result += "K"
      }
      if settings.whiteCastling.contains(.queenSide) {
        result += "Q"
      }
      if settings.blackCastling.contains(.kingSide) {
        result += "k"
      }
      if settings.blackCastling.contains(.queenSide) {
        result += "q"
      }
    }
    
    result += Constants.fenSeparator
    
    if let enPassant = settings.enPassant {
      result += enPassant.notation
    } else {
      result += Constants.fenEmptyField
    }
    
    result += Constants.fenSeparator
    
    result += "\(settings.plies)"
    
    result += Constants.fenSeparator
    
    result += "\(settings.blackMoves)"
    
    return result
  }
}
