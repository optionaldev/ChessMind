//
// The ChessMind project.
// Created by optionaldev on 17/11/2024.
// Copyright © 2024 optionaldev. All rights reserved.
// 

enum BoardHelper {
  
  /// Example of possible cases to handle:
  /// a4 -> Pawn moves to a4, could be from a2 or a3.
  /// dxc5 -> Pawn from d file captured piece on c5.
  /// Nc6 -> Only one knight can move to c6.
  /// N5c6 -> There are two knights on the a or e file,
  ///         and the one on the 5th rank is meant.
  /// Ne5c6 -> There are at least 3 knights that can
  ///          move to c6, two are on the e file and
  ///          two are on the 5th rank, so both file
  ///          and rank need to be specified.
  /// Ne5xc6 -> Same as above but with a capture.
  static func move(forNotation notation: String,
                   onBoard board: [[SquareState]],
                   turn: Turn) -> (move: Move, isCapture: Bool)?
  {
    /// We know for sure that the last two characters
    /// represent the destination rank and file, so
    /// we start there.
    guard notation.count >= 2 else {
      fatalError("Every notation is at least 2 characters long")
    }
    
    var notation = notation
    var index = notation.startIndex
    var isCapture = false
    
    while index < notation.endIndex {
      if notation[index] == "x" {
        /// We identified a capture.
        isCapture = true
        notation.remove(at: index)
        break
      }
      index = notation.index(after: index)
    }
    
    guard let destinationRank = Rank(character: notation.removeLast()) else {
      fatalError("Could not create rank.")
    }
    
    guard let destinationFile = File(character: notation.removeLast()) else {
      fatalError("Could not create file.")
    }
    
    let destinationPosition = Position(rank: destinationRank, file: destinationFile)
    
    /// _notation_ could at this point be empty.
    
    var startingPosition: Position?
    
    if notation.isEmpty {
      /// We have a pawn move. Side depends on "turn" parameter.
      /// We know it's a pawn advancement, not capture
      startingPosition = findPosition(forPiece: .pawn,
                                     onBoard: board,
                                     side: turn,
                                     thatCanMoveTo: destinationPosition)
    } else {
      let piece: Piece
      let notationCharacter = notation.removeFirst()
      if let pieceOptional = Piece(rawValue: notationCharacter) {
        piece = pieceOptional
      } else {
        /// If a piece was not found in the if part, it
        /// means that we're dealing with a pawn and
        /// this character represents its file.
        piece = .pawn
      }
      
      /// If notation is empty now, it means that only
      /// once piece can move to the destionation
      /// position, so we can start looking.
      if notation.isEmpty {
        startingPosition = findPosition(forPiece: piece,
                                        onBoard: board,
                                        side: turn,
                                        thatCanMoveTo: destinationPosition)
      } else {
        /// We have between 1 and 2 characters left.
        /// Either a rank, a file, or both.
        var file: File?
        var rank: Rank?
        
        if notation.count == 1 {
          /// Could be either rank or file, so we try both.
          let character = notation.removeFirst()
          file = File(character: character)
          rank = Rank(character: character)
        } else {
          file = File(character: notation.removeFirst())
          
          /// Could have also used removeFirst
          rank = Rank(character: notation.removeLast())
        }
        
        if let file = file,
            let rank = rank
        {
          startingPosition = Position(rank: rank, file: file)
        } else {
          startingPosition = findPosition(forPiece: piece,
                                          onBoard: board,
                                          side: turn,
                                          thatCanMoveTo: destinationPosition)
        }
      }
    }
    
    if let startingPosition = startingPosition {
      return (Move(from: startingPosition, to: destinationPosition), isCapture: isCapture)
    }
    return nil
  }
  
  static private func findPosition(forPiece expectedPiece: Piece,
                                   onBoard board: [[SquareState]],
                                   side expectedSide: Side,
                                   thatCanMoveTo position: Position) -> Position?
  {
    for row in board {
      for squareState in row {
        switch squareState {
          case .empty:
            continue
          case .occupied(let piece, let side):
            if piece == expectedPiece && side == expectedSide {
              /// Generate its moves and see if it's
              /// one of the possible moves.
            }
        }
      }
    }
    return nil
  }
}
