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
    
    print("Finding move for notation \(notation) turn = \(turn)")
    
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
    
    print("Have destination position = \(destinationPosition)")
    
    /// _notation_ could at this point be empty.
    
    var startingPosition: Position?
    
    if notation.isEmpty {
      print("notation is empty 1, must be pawn")
      /// We have a pawn move. Side depends on "turn" parameter.
      /// We know it's a pawn advancement, not capture
      startingPosition = findPosition(forPiece: .pawn,
                                      onBoard: board,
                                      side: turn,
                                      thatCanMoveTo: destinationPosition)
    } else {
      let piece: Piece
      let notationCharacter = notation.removeFirst()
      if let pieceOptional = Piece(rawValue: notationCharacter.lowercase) {
        piece = pieceOptional
      } else {
        /// If a piece was not found in the if part, it
        /// means that we're dealing with a pawn and
        /// this character represents its file.
        piece = .pawn
      }
      
      /// If notation is empty now, it means that only
      /// once piece can move to the destination
      /// position, so we can start looking.
      if notation.isEmpty {
        print("notation is empty 2, simple move, no ambiguity")
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
                                          rank: rank,
                                          file: file,
                                          thatCanMoveTo: destinationPosition)
        }
      }
    }
    
    if let startingPosition = startingPosition {
      return (Move(from: startingPosition, to: destinationPosition), isCapture: isCapture)
    }
    return nil
  }
  
  static func generatePossibleDestinations(forPosition position: Position,
                                           onBoard board: [[SquareState]],
                                           turn: Turn) -> [[Position]] {
    let theoreticalDestinationsMatrix = generateTheoreticalDestinations(forPosition: position, onBoard: board)
    
    guard case .occupied(_, let side) = board[position.row][position.column] else {
      return []
    }
    
    var result: [[Position]] = []
    var currentPositions: [Position] = []
    
    for destinationsArray in theoreticalDestinationsMatrix {
      for destination in destinationsArray {
        switch board[destination.row][destination.column] {
        case .empty:
          /// If the square is empty, we can move there.
          currentPositions.append(destination)
        case .occupied(_, let targetSide):
          /// If the square is not empty, we need to check if it's on our side.
          if side != targetSide {
            currentPositions.append(destination)
          } else {
          }
          
          result.append(currentPositions)
          currentPositions = []
          
        }
        if currentPositions.isEmpty {
          /// We can't break the for loop from inside the switch,
          /// so we do it here.
          break
        }
      }
    }
    
    if currentPositions.isNonEmpty {
      result.append(currentPositions)
    }
    
    return result
  }
  
  static func generateTheoreticalDestinations(forPosition position: Position,
                                              onBoard board: [[SquareState]]) -> [[Position]]
  {
    guard case .occupied(let piece, let side) = board[position.row][position.column] else {
      return []
    }
    
    var result: [[Position]] = []
    var currentMoves: [Position] = []
    
    let pinnedDirections = pinnedDirections(forPosition: position, onBoard: board, turn: side)
    
    switch piece {
    case .bishop:
      let directions = computeDirections([.bottomLeft, .bottomRight, .topLeft, .topRight], withPinnedDirections: pinnedDirections)
      result = generateTheoreticalDestinations(forDirections: directions,
                                               position: position)
    case .king:
      // TODO: Add castling moves
      /// King can never be pinned.
      for direction in Direction.allCases {
        if let newPosition = position.next(inDirection: direction) {
          result.append([newPosition])
        }
      }
    case .knight:
      /// If knight is pinned, knight can never capture its pinner.
      if pinnedDirections.isEmpty {
        for direction in KnightDirection.allCases {
          if let newPosition = position.next(inDirection: direction) {
            result.append([newPosition])
          }
        }
      }
    case .pawn:
      let advanceDirection: Direction?
      let captureDirections: [Direction]
      switch side {
      case .black:
        advanceDirection = computeDirections([.down], withPinnedDirections: pinnedDirections).first
        captureDirections = computeDirections([.bottomLeft, .bottomRight], withPinnedDirections: pinnedDirections)
      case .white:
        advanceDirection = computeDirections([.up], withPinnedDirections: pinnedDirections).first
        captureDirections = computeDirections([.topLeft, .topRight], withPinnedDirections: pinnedDirections)
      }
      let canGoTwoSquares = (side == .black && position.rank == .seventh) ||
      (side == .white && position.rank == .second)
      
      if let advanceDirection = advanceDirection {
        if let newPosition = position.next(inDirection: advanceDirection) {
          currentMoves.append(newPosition)
          if canGoTwoSquares,
             let twoSquaresAdvancePosition = newPosition.next(inDirection: advanceDirection)
          {
            currentMoves.append(twoSquaresAdvancePosition)
          }
        }
      }
      result.append(currentMoves)
      
      for direction in captureDirections {
        if let newPosition = position.next(inDirection: direction) {
          switch board[newPosition.row][newPosition.column] {
          case .empty:
            break
          case .occupied(_, let targetSide):
            if targetSide != side {
              result.append([newPosition])
            }
          }
        }
      }
      
    case .queen:
      let directions = computeDirections(Direction.allCases, withPinnedDirections: pinnedDirections)
      result = generateTheoreticalDestinations(forDirections: directions,
                                               position: position)
    case .rook:
      let directions = computeDirections([.down, .left, .right, .up], withPinnedDirections: pinnedDirections)
      result = generateTheoreticalDestinations(forDirections: directions,
                                               position: position)
    }
    
    return result
  }
  
  // MARK: - Private
  
  private static func checkIfPosition(position: Position,
                                      canMoveTo destionation: Position,
                                      onBoard board: [[SquareState]],
                                      forPiece expectedPiece: Piece,
                                      side expectedSide: Side,
                                      squareState: SquareState) -> Bool
  {
    switch squareState {
    case .empty:
      return false
    case .occupied(let piece, let side):
      if piece == expectedPiece && side == expectedSide {
        let possibleDestinations = generatePossibleDestinations(forPosition: position, onBoard: board, turn: side)
        print("Possible destionations for \(piece) side = \(side) at position = \(position) are \(possibleDestinations)" )
        
        if possibleDestinations.flatMap({ $0 }).contains(destionation) {
          return true
        }
      }
    }
    return false
  }
  
  private static func computeDirections(_ directions: [Direction], withPinnedDirections pinnedDirections: [Direction]) -> [Direction] {
    guard pinnedDirections.isNonEmpty else {
      return directions
    }
    
    return directions.filter { pinnedDirections.contains($0) }
  }
  
  static private func findDirectionOfKing(forPosition position: Position,
                                          onBoard board: [[SquareState]],
                                          direction: Direction) -> Direction? {
    guard case .occupied(_, let side) = board[position.row][position.column] else {
      return nil
    }
    var referencePosition = position
    
    while let newPosition = referencePosition.next(inDirection: direction) {
      switch board[newPosition.row][newPosition.column] {
      case .empty:
        break
      case .occupied(let referencePiece, let referenceSide):
        if referencePiece == .king && side == referenceSide {
          return direction
        } else {
          /// We break because we found another piece and we're looking
          /// for the king. If the king is futher than the piece we found,
          /// there's no pin happening.
          return nil
        }
      }
      referencePosition = newPosition
    }
    
    return nil
  }
  
  private static func findPosition(forPiece expectedPiece: Piece,
                                   onBoard board: [[SquareState]],
                                   side expectedSide: Side,
                                   thatCanMoveTo destination: Position) -> Position?
  {
    print("findPosition piece = \(expectedPiece) side = \(expectedSide) destination = \(destination)")
    for (row, boardRow) in board.enumerated() {
      for (column, squareState) in boardRow.enumerated() {
        if let position = Position(row: row, column: column),
           checkIfPosition(position: position,
                           canMoveTo: destination,
                           onBoard: board,
                           forPiece: expectedPiece,
                           side: expectedSide,
                           squareState: squareState)
        {
          return position
        }
      }
    }
    return nil
  }
  private static func findPosition(forPiece expectedPiece: Piece,
                                   onBoard board: [[SquareState]],
                                   side expectedSide: Side,
                                   rank: Rank?,
                                   file: File?,
                                   thatCanMoveTo destination: Position) -> Position?
  {
    let boardSlice: [SquareState]
    
    if let rank = rank {
      boardSlice = board[rank.rawValue]
    } else if let file = file {
      boardSlice = board.map { $0[file.rawValue] }
    } else {
      fatalError("Shouldn't call this method if we don't have either a rank or a file.")
    }
    
    for (index, squareState) in boardSlice.enumerated() {
      if let position = Position(row: rank?.rawValue ?? index, column: file?.rawValue ?? index),
         checkIfPosition(position: position,
                                     canMoveTo: destination,
                                     onBoard: board,
                                     forPiece: expectedPiece,
                                     side: expectedSide,
                                     squareState: squareState)
      {
        return position
      }
    }
    return nil
  }
  
  private static  func findPossiblePins(forPosition position: Position,
                                        onBoard board: [[SquareState]],
                                        direction: Direction,
                                        turn: Turn,
                                        possiblePinnedDirections: [Direction]) -> [Direction]
  {
    var referencePosition = position
    while let newPosition = referencePosition.next(inDirection: direction) {
      switch board[newPosition.row][newPosition.column] {
      case .empty:
        break
      case .occupied(let referencePiece, let referenceSide):
        if referenceSide != turn {
          if direction.isDiagonal && (referencePiece == .queen || referencePiece == .bishop) {
            /// Only bishops and queens can pin on diagonals.
            return possiblePinnedDirections
            
          } else if direction.isDiagonal == false && (referencePiece == .queen || referencePiece == .rook) {
            /// Only queens and rooks can pin on ranks / files.
            return possiblePinnedDirections
          } else {
            return []
          }
        } else {
          return []
        }
      }
      
      referencePosition = newPosition
    }
    
    return []
  }
  
  private static func generateTheoreticalDestinations(forDirections directions: [Direction],
                                                      position: Position) -> [[Position]] {
    var result: [[Position]] = []
    var currentDestinations: [Position] = []
    
    for direction in directions {
      var referencePosition = position
      while let newPosition = referencePosition.next(inDirection: direction) {
        currentDestinations.append(newPosition)
        referencePosition = newPosition
      }
      if currentDestinations.isNonEmpty {
        result.append(currentDestinations)
      }
      
      currentDestinations = []
    }
    
    return result
  }
  
  /// The aim of this method is to find directions for which a position is pinned
  /// If for example, the king is on e1 and the position we're trying to
  /// calculate for is e2, then we know that e2 can be pinned up / down,
  /// but not left / right. This means that a pawn will be able to advance,
  /// but not capture. A queen will be able to advance anywhere on the
  /// file, including capturing the pinner.
  static private func pinnedDirections(forPosition position: Position,
                                       onBoard board: [[SquareState]],
                                       turn: Turn) -> [Direction]
  {
    guard case .occupied(let piece, _) = board[position.row][position.column] else {
      return []
    }
    
    /// There's no point in calculating pinnings for king,
    /// whether it's white or black king.
    guard piece != .king else {
      return []
    }
    
    var kingDirection: Direction?
    
    for direction in Direction.allCases {
      if let foundKingDirection = findDirectionOfKing(forPosition: position, onBoard: board, direction: direction) {
        kingDirection = foundKingDirection
      }
    }
    
    guard let kingDirection = kingDirection else {
      return []
    }
    
    let possiblePinnedDirections = [kingDirection, kingDirection.opposite]
    
    for direction in possiblePinnedDirections {
      let result = findPossiblePins(forPosition: position,
                                    onBoard: board,
                                    direction: direction,
                                    turn: turn,
                                    possiblePinnedDirections: possiblePinnedDirections)
      
      if result.isNonEmpty {
        return result
      }
    }
    
    return []
  }
}
