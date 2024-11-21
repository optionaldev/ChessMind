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
    
    let settings = BoardSettings(
      blackCastling: [fenCastlingRights.contains("k") ? .kingSide : nil,
                      fenCastlingRights.contains("q") ? .queenSide : nil].compactMap { $0 },
      blackMoves: fenBlackMoves,
      enPassant: fenEnPassant,
      plies: fenPlies,
      turn: fenTurn == "w" ? .white : .black,
      whiteCastling: [fenCastlingRights.contains("K") ? .kingSide : nil,
                      fenCastlingRights.contains("Q") ? .queenSide : nil].compactMap { $0 })
    
    return (board, settings)
  }
  
  static func fen(fromSquares squares: [SquareState], settings: BoardSettings) -> String {
    var result = ""
    var currentEmptySquares = 0
    var currentColumn = 0
    var currentRow = 0
    
    for square in squares {
      switch square {
        case .empty:
          currentEmptySquares += 1
        case .occupied(let piece, let side):
          if currentEmptySquares != 0 {
            result += "\(currentEmptySquares)"
          }
          
          result.append(FenHelper.notation(forPiece: piece, side: side))
          
      }
      if currentColumn + 1 == Constants.boardLength {
        if currentEmptySquares != 0 {
          result += "\(currentEmptySquares)"
        }
        if currentRow + 1 != Constants.boardLength {
          result += "/"
          currentEmptySquares = 0
          currentColumn = 0
          currentRow += 1
        }
      } else {
        currentColumn += 1
      }
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
