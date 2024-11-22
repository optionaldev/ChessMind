//
// The ChessMind project.
// Created by optionaldev on 17/11/2024.
// Copyright © 2024 optionaldev. All rights reserved.
//

enum BoardHelper {
  
  static func findKing(onBoard board: [[SquareState]],
                       boardSettings: BoardSettings) -> Position
  {
    for (row, boardRow) in board.enumerated() {
      for (column, squareState) in boardRow.enumerated() {
        if case .occupied(let piece, let side) = squareState,
           piece == .king && side == boardSettings.turn,
           let position = Position(row: row, column: column)
        {
          return position
        }
      }
    }
    fatalError("Should always have a king")
  }
  
  static func isKingInCheck(onBoard board: [[SquareState]],
                            boardSettings: BoardSettings) -> Bool
  {
    let kingPosition = findKing(onBoard: board, boardSettings: boardSettings)
    
    return isPositionUnderAttack(kingPosition, onBoard: board, boardSettings: boardSettings)
  }
  
  static func generateLegalDestinations(forPosition position: Position,
                                        onBoard board: [[SquareState]],
                                        boardSettings: BoardSettings) -> [Position]
  {
    var potentialBlockingSquares: [Position] = []
    
    if boardSettings.kingIsInCheck {
      let kingPosition = findKing(onBoard: board, boardSettings: boardSettings)
      let directionOfCheck = findDirectionOfCheck(onBoard: board, boardSettings: boardSettings)
      let enemyPosition = enemyAttackPosition(kingPosition, onBoard: board, boardSettings: boardSettings)
      
      var referencePosition = kingPosition
      while var newPosition = referencePosition.next(inDirection: directionOfCheck) {
        potentialBlockingSquares.append(newPosition)
        referencePosition = newPosition
      }
    }
    let theoreticalDestinationsMatrix = generateTheoreticalDestinations(forPosition: position,
                                                                        onBoard: board,
                                                                        boardSettings: boardSettings)
    
    guard case .occupied(_, let side) = board[position.row][position.column] else {
      return []
    }
    
    var result: [[Position]] = []
    var currentPositions: [Position] = []
    
    for destinationsArray in theoreticalDestinationsMatrix {
      for destination in destinationsArray {
        if potentialBlockingSquares.isEmpty || potentialBlockingSquares.contains(destination) {
          switch board[destination.row][destination.column] {
            case .empty:
              /// If the square is empty, we can move there.
              currentPositions.append(destination)
            case .occupied(_, let targetSide):
              /// If the square is not empty, we need to check if it's on our side.
              if side != targetSide {
                currentPositions.append(destination)
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
    }
    
    if currentPositions.isNonEmpty {
      result.append(currentPositions)
    }
    
    return result.flatMap { $0 }
  }
  
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
                   boardSettings: BoardSettings) -> [(move: Move, isCapture: Bool)]
  {
    /// We know for sure that the last two characters
    /// represent the destination rank and file, so
    /// we start there.
    guard notation.count >= 2 else {
      fatalError("Every notation is at least 2 characters long")
    }
    
    if notation == Constants.shortCastlingNotation || notation == Constants.longCastlingNotation {
      let moves = castlingMoves(forNotation: notation, onBoard: board, turn: boardSettings.turn)
      return moves.map { ($0, isCapture: false) }
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
    
    if notation.last == "+" || notation.last == "#" {
      /// For now, we ignore checks and checkmate symbols
      notation.removeLast()
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
                                      boardSettings: boardSettings,
                                      thatCanMoveTo: destinationPosition)
    } else {
      let piece: Piece
      let notationCharacter = notation.removeFirst()
      if notationCharacter.isUppercase,
         let pieceOptional = Piece(rawValue: notationCharacter.lowercase)
      {
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
        startingPosition = findPosition(forPiece: piece,
                                        onBoard: board,
                                        boardSettings: boardSettings,
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
                                          boardSettings: boardSettings,
                                          rank: rank,
                                          file: file,
                                          thatCanMoveTo: destinationPosition)
        }
      }
    }
    
    if let startingPosition = startingPosition {
      return [(Move(from: startingPosition, to: destinationPosition), isCapture: isCapture)]
    }
    return []
  }
  
  // MARK: - Private
  
  private static func castlingMoves(forNotation notation: String,
                                    onBoard board: [[SquareState]],
                                    turn: Turn) -> [Move]
  {
    switch turn {
    case .black:
      if notation == Constants.shortCastlingNotation {
        return [Move(from: Position(rank: .eighth, file: .h), to: Position(rank: .eighth, file: .f)),
                Move(from: Position(rank: .eighth, file: .e), to: Position(rank: .eighth, file: .g))]
      } else {
        return [Move(from: Position(rank: .eighth, file: .a), to: Position(rank: .eighth, file: .d)),
                Move(from: Position(rank: .eighth, file: .e), to: Position(rank: .eighth, file: .c))]
      }
    case .white:
      if notation == Constants.shortCastlingNotation {
        return [Move(from: Position(rank: .first, file: .h), to: Position(rank: .first, file: .f)),
                Move(from: Position(rank: .first, file: .e), to: Position(rank: .first, file: .g))]
      } else {
        return [Move(from: Position(rank: .first, file: .a), to: Position(rank: .first, file: .d)),
                Move(from: Position(rank: .first, file: .e), to: Position(rank: .first, file: .c))]
      }
    }
  }
    
  private static func checkIfPosition(position: Position,
                                      canMoveTo destination: Position,
                                      onBoard board: [[SquareState]],
                                      boardSettings: BoardSettings,
                                      forPiece expectedPiece: Piece,
                                      squareState: SquareState) -> Bool
  {
    switch squareState {
    case .empty:
      return false
    case .occupied(let piece, let side):
      if piece == expectedPiece && side == boardSettings.turn {
        let legalDestinations = generateLegalDestinations(forPosition: position, onBoard: board, boardSettings: boardSettings)
        if legalDestinations.contains(destination) {
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
  
  static private func findDirectionOfCheck(onBoard board: [[SquareState]],
                                           boardSettings: BoardSettings) -> Direction
  {
    let kingPosition = findKing(onBoard: board, boardSettings: boardSettings) 
    
    if let enemy = enemyAttackPosition(kingPosition, onBoard: board, boardSettings: boardSettings) {
      for direction in Direction.allCases {
        if kingPosition.next(inDirection: direction) == enemy {
          return direction
        }
      }
    }
    fatalError("Should always have a direction, otherwise the king is not in check.")
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
                                   boardSettings: BoardSettings,
                                   thatCanMoveTo destination: Position) -> Position?
  {
    for (row, boardRow) in board.enumerated() {
      for (column, squareState) in boardRow.enumerated() {
        if let position = Position(row: row, column: column),
           checkIfPosition(position: position,
                           canMoveTo: destination,
                           onBoard: board,
                           boardSettings: boardSettings,
                           forPiece: expectedPiece,
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
                                   boardSettings: BoardSettings,
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
                         boardSettings: boardSettings,
                         forPiece: expectedPiece,
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
  
  static private func generateTheoreticalDestinations(forPosition position: Position,
                                                      onBoard board: [[SquareState]],
                                                      boardSettings: BoardSettings) -> [[Position]]
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
      /// King can never be pinned.
      for direction in Direction.allCases {
        if let newPosition = position.next(inDirection: direction),
           isPositionUnderAttack(newPosition, onBoard: board, boardSettings: boardSettings) == false
        {
          result.append([newPosition])
        }
      }
      let castlingRank: Rank
      switch boardSettings.turn {
      case .black:
        castlingRank = .eighth
      case .white:
        castlingRank = .first
      }
      
      for castlingRight in boardSettings.currentSideCastlingRights {
        if castlingRight == CastlingSide.kingSide &&
            isPositionUnderAttack(Position(rank: castlingRank, file: .f),
                                  onBoard: board,
                                  boardSettings: boardSettings) == false &&
            isPositionUnderAttack(Position(rank: castlingRank, file: .g),
                                  onBoard: board,
                                  boardSettings: boardSettings) == false
        {
          result.append([Position(rank: castlingRank, file: .g)])
        } else if castlingRight == CastlingSide.queenSide &&
                    isPositionUnderAttack(Position(rank: castlingRank, file: .d),
                                          onBoard: board,
                                          boardSettings: boardSettings) == false &&
                    isPositionUnderAttack(Position(rank: castlingRank, file: .c),
                                          onBoard: board,
                                          boardSettings: boardSettings) == false
        {
          result.append([Position(rank: castlingRank, file: .c)])
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
      
      if let advanceDirection = advanceDirection {
        if let newPosition = position.next(inDirection: advanceDirection),
           case .empty = board[newPosition.row][newPosition.column]
        {
          currentMoves.append(newPosition)
          
          let canGoTwoSquares = (side == .black && position.rank == .seventh) ||
          (side == .white && position.rank == .second)
          
          if canGoTwoSquares,
             let twoSquaresAdvancePosition = newPosition.next(inDirection: advanceDirection),
             case .empty = board[twoSquaresAdvancePosition.row][twoSquaresAdvancePosition.column]
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
            if let enPassantPosition = boardSettings.enPassant {
              if newPosition == enPassantPosition {
                result.append([newPosition])
              }
            }
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
  private static func isPositionUnderAttack(_ position: Position, 
                                            onBoard board: [[SquareState]],
                                            boardSettings: BoardSettings) -> Bool
  {
    return enemyAttackPosition(position, onBoard: board, boardSettings: boardSettings) != nil
  }
  
  private static func enemyAttackPosition(_ position: Position,
                                          onBoard board: [[SquareState]],
                                          boardSettings: BoardSettings) -> Position?
  {
    for (row, boardRow) in board.enumerated() {
      for (column, squareState) in boardRow.enumerated() {
        switch squareState {
          case .empty:
            break
          case .occupied(let piece, let side):
            guard piece != .king && side != boardSettings.turn else {
              break
            }
            if let enemyPosition = Position(row: row, column: column) {
              let legalDestinations = generateLegalDestinations(forPosition: enemyPosition,
                                                                onBoard: board,
                                                                boardSettings: boardSettings)
              if legalDestinations.contains(position) {
                return enemyPosition
              }
            }
        }
      }
    }
    return nil
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
