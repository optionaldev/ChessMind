//
// The ChessMind project.
// Created by optionaldev on 17/11/2024.
// Copyright © 2024 optionaldev. All rights reserved.
//

enum BoardHelper {
  
  /// Find the king for the side that is next to move.
  ///
  /// This method assumes that both sides have a king on the board.
  ///
  /// - Returns: The position of the king for the side that is next
  /// to move.
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
    fatalError("Should always have a king (on both sides).")
  }
  
  /// Method for finding out if the king for the side that is next to
  /// move is in check.
  ///
  /// It's important to know whether the king is in check or not
  /// because the amount of legal moves that exist on the board if the
  /// king is in check is always lower.
  ///
  /// - Returns: true if king is in check, false otherwise.
  static func isKingInCheck(onBoard board: [[SquareState]],
                            boardSettings: BoardSettings) -> Bool
  {
    if case .notInCheck = computeCheckState(onBoard: board, boardSettings: boardSettings) {
      return false
    }
    return true
  }
  
  /// Calculates the squares on which the input piece can legally move.
  ///
  /// This method takes into account:
  /// - whether the piece is pinned
  /// - whether the piece can block a check if
  /// needed
  /// - whether the piece can capture the
  /// piece that is checking the king
  ///
  /// - Parameters:
  ///   - forPieceAtPosition: the position of the piece for which the
  ///   calculations are being done.
  ///
  /// - Returns: Destination squares that the input piece can go to.
  static func calculateLegalDestinations(forPieceAtPosition position: Position,
                                         onBoard board: [[SquareState]],
                                         boardSettings: BoardSettings) -> [Position]
  {
    guard case .occupied(let piece, let side) = board[position.row][position.column] else {
      fatalError("Should not call this method with position being an empty square.")
    }
    
    
    guard let checkInfo = calculateCheckInfo(forPieceAtPosition: position,
                                             onBoard: board,
                                             boardSettings: boardSettings) else
    {
      return []
    }
    
    let theoreticalDestinationMatrix = calculateTheoreticalDestinations(forPieceAtPosition: position,
                                                                        isKingInCheck: checkInfo.isInCheck,
                                                                        onBoard: board,
                                                                        boardSettings: boardSettings)
    
    var result: [[Position]] = []
    var currentPositions: [Position] = []
    
    for destinationArray in theoreticalDestinationMatrix {
    innerFor:
      for destination in destinationArray {
        switch board[destination.row][destination.column] {
          case .empty:
            /// If the square is empty, we can move there.
            if isValid(destination: destination,
                       forPiece: piece,
                       withCheckInfo: checkInfo,
                       onBoard: board,
                       boardSettings: boardSettings)
            {
              currentPositions.append(destination)
            }
            
          case .occupied(_, let targetSide):
            /// If the square is not empty, we need to check if
            /// it's on our side.
            if side != targetSide &&
                isValid(destination: destination,
                        forPiece: piece,
                        withCheckInfo: checkInfo,
                        onBoard: board,
                        boardSettings: boardSettings)
            {
              currentPositions.append(destination)
            }
            
            result.append(currentPositions)
            currentPositions = []
            break innerFor
        }
      }
    }
    
    if currentPositions.isNonEmpty {
      result.append(currentPositions)
    }
    
    return result.flatMap { $0 }
  }
  
  
  private static func isValid(destination: Position,
                              forPiece piece: Piece,
                              withCheckInfo checkInfo: CheckInfo,
                              onBoard board: [[SquareState]],
                              boardSettings: BoardSettings) -> Bool
  {
    switch piece {
      case .bishop, .knight, .pawn, .queen, .rook:
        if checkInfo.validPositionsForNonKingPieces.isEmpty ||
            checkInfo.validPositionsForNonKingPieces.contains(destination)
        {
          return true
        }
      case .king:
        /// We check for opposite position, because king can't stay
        /// on the same file/rank/diagonal he was checked on.
        if destination != checkInfo.oppositeSideOfCheck &&
            isProtectedSquare(destination,
                              onBoard: board,
                              boardSettings: boardSettings) == false
        {
          return true
        }
    }
    return false
  }
  
  /// Get the move(s) involved in a notation.
  ///
  /// Example of possible cases:
  /// - a4 -> Pawn moves to a4, could be from a2 or a3.
  /// - dxc5 -> Pawn from d file captured piece on c5.
  /// - Nc6 -> Only one knight can move to c6.
  /// - N5c6 -> There are two knights on the a or e file,
  ///         and the one on the 5th rank is meant.
  /// - Ne5c6 -> There are at least 3 knights that can
  ///          move to c6, two are on the e file and
  ///          two are on the 5th rank, so both file
  ///          and rank need to be specified.
  /// - Ne5xc6 -> Same as above but with a capture.
  ///
  /// - Parameters:
  ///   - forNotation: algebraic notation that needs to be converted
  ///   into moves.
  ///
  /// - Returns: An array of moves and capture statuses. If notation
  /// can be converted into moves, max 2 for castling, max 1
  /// otherwise. Empty array if notation could not be converted into
  /// moves.
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
    
    if notation == Constants.castlingShortNotation || notation == Constants.castlingLongNotation {
      let moves = castlingMoves(forNotation: notation, turn: boardSettings.turn)
      return moves.map { ($0, isCapture: false) }
    }
    
    var notation = notation
    var index = notation.startIndex
    var isCapture = false
    
    while index < notation.endIndex {
      if notation[index] == Constants.captureNotation {
        isCapture = true
        notation.remove(at: index)
        break
      }
      index = notation.index(after: index)
    }
    
    if notation.last == Constants.checkNotation || notation.last == "#" {
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
      startingPosition = findPosition(ofPiece: .pawn,
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
        startingPosition = findPosition(ofPiece: piece,
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
          startingPosition = findPosition(ofPiece: piece,
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
  
  /// Get the algebraic notation for the given move(s).
  ///
  /// - Parameters:
  ///   - forMove: move that happened
  ///   - fromSquare: information about the origin square from which
  ///   the move happened BEFORE it happened
  ///   - toSquare: information about the destination square to which
  ///   the move happened BEFORE it happened
  ///
  /// - Returns: Algebraic notation for the given set of moves. E.g:
  /// "O-O" for short castling, "a5" for pawn advancing from a4 to a5
  /// (white) or a6 to a5 (black), etc
  static func notation(forMove move: Move,
                       fromSquare: SquareState,
                       toSquare: SquareState,
                       onBoard board: [[SquareState]],
                       boardSettings: BoardSettings) -> String?
  {
    switch fromSquare {
      case .empty:
        fatalError("Not possible to move from an empty square. What are we trying to move?")
      case .occupied(let fromPiece, let fromSide):
        var isCapture: Bool
        switch toSquare {
          case .empty:
            isCapture = false
          case .occupied(_, let toSide):
            guard fromSide != toSide else {
              fatalError("We're trying to capture a piece from the same side???")
            }
            isCapture = true
        }
        /// Here we need to know if another piece identical to
        /// 'fromPiece' from the same side as 'fromSide' can
        /// move to the same square. For example, a knight on
        /// c3 and a Knight on g3 and both move to e4, which
        /// affects the notation because the notation includes
        /// information about which knight should land on the
        /// destination square.
        
        switch fromPiece {
          case .pawn:
            if isCapture {
              return "\(move.from.file.notation)\(Constants.captureNotation)\(move.to.notation)"
            } else {
              return move.to.notation
            }
          case .king:
            
            if abs(move.from.file.rawValue - move.to.file.rawValue) == 2 {
              /// We castled, so we need to return the appropriate
              /// notation.
              if move.to.file == .c {
                return Constants.castlingLongNotation
              } else {
                return Constants.castlingShortNotation
              }
            } else {
              /// We handle king separately because there can only
              /// be one king, meaning there's no point in looking
              /// for other pieces that can go to the destination
              /// square.
              return "K\(move.to.notation)"
            }
          case .bishop, .knight, .queen, .rook:
            /// We need to calculate the legal destinations of all
            /// pieces of the same type from the same side (e.g:
            /// all white knights, all white queens, etc).
            /// If there are two knights, one on c3 and one on g3,
            /// if the g3 knight is pinned to the king, and the c3
            /// knight moves to e4, the notation is "Ne4"
            let (sameRank, sameFile) = findSamePieces(as: fromPiece,
                                                      side: fromSide,
                                                      from: move.from,
                                                      thatCanMoveTo: move.to,
                                                      onBoard: board,
                                                      boardSettings: boardSettings)
            var result = fromPiece.rawValue.uppercased()
            if sameRank && sameFile {
              /// If both rank and file are available, it means
              /// there are three pieces that can go to the same
              /// position. Two of them are on the same rank, two
              /// of them are on the same file (not exclusive)
              result += move.from.notation
            } else if sameRank {
              result += move.from.file.notation.string
            } else if sameFile {
              result += move.from.rank.notation
            }
            
            if isCapture {
              result += Constants.captureNotation.string
            }
            
            result += move.to.notation
            
            if isKingInCheck(onBoard: board, boardSettings: boardSettings) {
              result += Constants.checkNotation.string
            }
            
            return result
        }
    }
  }
  
  // MARK: - Private
  
  /// Gets the check info for the input piece.
  ///
  /// Calculating the check info does not mean that the side from
  /// where the piece belongs is in check, but if it is, it holds the
  /// limits for the input piece, because the piece might not be able
  /// to move at all if it can't do something about the check such as
  /// blocking or capturing the attacking piece.
  ///
  /// - Parameters:
  ///   - forPieceAtPosition: the piece for which we calculate the
  ///   check info.
  ///
  /// - Returns: Information about the check, if the side of the piece
  /// is indeed in check. If _nil_ it means that the input piece has
  /// no legal moves at the moment.
  private static func calculateCheckInfo(forPieceAtPosition position: Position,
                                         onBoard board: [[SquareState]],
                                         boardSettings: BoardSettings) -> CheckInfo?
  {
    guard case .occupied(let piece, let side) = board[position.row][position.column] else {
      return nil
    }
    
    /// This method is called for both white pieces
    /// and black pieces. If it's the side for which
    /// the current turn is, we need to also look
    /// if the king is in check.
    let checkState: CheckState
    if side == boardSettings.turn {
      checkState = computeCheckState(onBoard: board, boardSettings: boardSettings)
    } else {
      /// Only the side who's turn it is can be in check.
      checkState = .notInCheck
    }
    
    var nonKingValidPositionsDuringCheck: [Position] = []
    
    /// When the king is in check, he cannot walk in
    /// the opposite direction of the check direciton.
    var oppositePositionOfCheck: Position?
    
    switch checkState {
      case .notInCheck:
        /// When the king is not in check, legal
        /// moves are not affected.
        break
      case .checkedByOnePiece(let attackingPosition, let attackingDirection):
        /// When the king is checked by one enemy piece, we need
        /// to find all the squares between the attacking piece
        /// and the king that are empty, because those could be
        /// occupied by the current moving side's pieces to stop
        /// the check.
        nonKingValidPositionsDuringCheck.append(attackingPosition)
        var referencePosition = findKing(onBoard: board, boardSettings: boardSettings)
        oppositePositionOfCheck = referencePosition.next(inDirection: attackingDirection.opposite)
        
      outerLoop:
        while let newPosition = referencePosition.next(inDirection: attackingDirection) {
          switch board[newPosition.row][newPosition.column] {
            case .empty:
              nonKingValidPositionsDuringCheck.append(newPosition)
            case .occupied:
              break outerLoop
          }
          
          referencePosition = newPosition
        }
      case .checkedByKnight(let opponentKnightPosition):
        nonKingValidPositionsDuringCheck.append(opponentKnightPosition)
      case .checkedByTwoPieces:
        /// When the king is in check by two pieces (also
        /// known as double check), the king has to move,
        /// because no piece can block two attacks at
        /// the same time.
        if side == boardSettings.turn && piece != .king {
          return nil
        }
    }
    
    return CheckInfo(checkState: checkState,
                     validPositionsForNonKingPieces: nonKingValidPositionsDuringCheck,
                     oppositeSideOfCheck: oppositePositionOfCheck)
  }
  
  /// Converts the notation and turn into the 2 castling moves.
  ///
  /// - Parameters:
  ///   - forNotation: the algebraic notation for castling (either
  ///   short or long)
  ///
  /// - Returns: The moves involved in castling. This method always
  /// returns two moves, even if the notation is incorrect.
  private static func castlingMoves(forNotation notation: String,
                                    turn: Turn) -> [Move]
  {
    switch turn {
      case .black:
        if notation == Constants.castlingShortNotation {
          return [Move(from: Position(rank: .eighth, file: .h), to: Position(rank: .eighth, file: .f)),
                  Move(from: Position(rank: .eighth, file: .e), to: Position(rank: .eighth, file: .g))]
        } else {
          return [Move(from: Position(rank: .eighth, file: .a), to: Position(rank: .eighth, file: .d)),
                  Move(from: Position(rank: .eighth, file: .e), to: Position(rank: .eighth, file: .c))]
        }
      case .white:
        if notation == Constants.castlingShortNotation {
          return [Move(from: Position(rank: .first, file: .h), to: Position(rank: .first, file: .f)),
                  Move(from: Position(rank: .first, file: .e), to: Position(rank: .first, file: .g))]
        } else {
          return [Move(from: Position(rank: .first, file: .a), to: Position(rank: .first, file: .d)),
                  Move(from: Position(rank: .first, file: .e), to: Position(rank: .first, file: .c))]
        }
    }
  }
  
  /// Check if the piece at a certain position can move to another
  /// position.
  ///
  /// This method takes into account king being in check and piece
  /// being pinned.
  ///
  /// - Parameters:
  ///   - ifPiece: the piece we expect to find at the input position
  ///   - atPosition: the position we need to check to see if the
  ///   input piece can move to
  ///   - canMoveTo: destination of input piece that we need to
  ///   validate if possible
  ///
  /// - Returns: true if input piece can move to destination,
  /// including checking any pins or king being in check
  private static func check(ifPiece expectedPiece: Piece,
                            atPosition position: Position,
                            canMoveTo destination: Position,
                            onBoard board: [[SquareState]],
                            boardSettings: BoardSettings) -> Bool
  {
    switch board[position.row][position.column] {
      case .empty:
        return false
      case .occupied(let piece, let side):
        if piece == expectedPiece && side == boardSettings.turn {
          let legalDestinations = calculateLegalDestinations(forPieceAtPosition: position,
                                                             onBoard: board,
                                                             boardSettings: boardSettings)
          if legalDestinations.contains(destination) {
            return true
          }
        }
    }
    return false
  }
  
  /// Filters _directions_ to only include those already contained
  /// in _pinnedDirections_ (legal directions)
  ///
  /// - Parameters:
  ///   - directions: directions that a piece can normally go in
  ///   - withPinnedDirections: the directions that the piece is
  ///   pinned to the king on
  ///
  /// - Returns: filtered directions to only include legal directions
  private static func filterDirections(_ directions: [Direction],
                                        withPinnedDirections pinnedDirections: [Direction]) -> [Direction] {
    
    guard pinnedDirections.isNonEmpty else {
      /// If there's no pinned directions, there's nothing to filter
      return directions
    }
    
    return directions.filter { pinnedDirections.contains($0) }
  }
  
  /// Get the check state for the current side to move.
  ///
  /// - Returns: the current check state
  static private func computeCheckState(onBoard board: [[SquareState]],
                                        boardSettings: BoardSettings) -> CheckState
  {
    let kingPosition = findKing(onBoard: board, boardSettings: boardSettings)
    
    let enemyPositions = findEnemiesAttackingPosition(kingPosition, onBoard: board, boardSettings: boardSettings)
    
    if enemyPositions.isEmpty {
      return .notInCheck
    } else if enemyPositions.count == 2 {
      return .checkedByTwoPieces
    } else if enemyPositions.count == 1,
              let enemyPosition = enemyPositions.first
    {
      for direction in Direction.allCases {
        var referencePosition = kingPosition
        while let newPosition = referencePosition.next(inDirection: direction) {
          if newPosition == enemyPosition {
            return .checkedByOnePiece(atPosition: enemyPosition, fromDirection: direction)
          }
          referencePosition = newPosition
        }
      }
      
      return .checkedByKnight(atPosition: enemyPosition)
    }
    
    fatalError("Somehow, we've avoided all possible check types: \(enemyPositions)")
  }
  
  /// Check if the piece at the input position is protected by another
  /// piece from the same side. Useful to know during check if the
  /// king can capture the input piece or not.
  ///
  /// This method assumes that the king is in check.
  ///
  /// - Parameters:
  ///   - position: position of piece to check if it is protected
  ///
  /// - Returns: _true_ if the piece is protected, _false_ otherwise
  private static func isProtectedSquare(_ position: Position,
                                        onBoard board: [[SquareState]],
                                        boardSettings: BoardSettings) -> Bool
  {
    guard case .occupied(_, let side) = board[position.row][position.column] else {
      return false
    }
    
    /// Since we only use this method when a king is in check, we only
    /// need to know if the opponent's pieces are protected.
    guard side != boardSettings.turn else {
      return false
    }
    
    for (row, boardRow) in board.enumerated() {
      for (column, squareState) in boardRow.enumerated() {
        switch squareState {
          case .empty:
            break
          case .occupied(_, let foundSide):
            if side == foundSide,
               let allyPosition = Position(row: row, column: column)
            {
              let theoreticalDestinationMatrix = calculateTheoreticalDestinations(forPieceAtPosition: allyPosition,
                                                                             isKingInCheck: false,
                                                                             onBoard: board,
                                                                             boardSettings: boardSettings)
              
              for destinationArray in theoreticalDestinationMatrix {
              innerLoop:
                for destination in destinationArray {
                  switch board[destination.row][destination.column] {
                    case .empty:
                      break
                    case .occupied:
                      if position == destination {
                        return true
                      } else {
                        /// If the square is occupied, but we haven't
                        /// found a match for our input position,
                        /// there's no point in looking further on
                        /// this direction.
                        break innerLoop
                      }
                  }
                }
              }
            }
        }
      }
    }
    return false
  }
  
  private static func findDirectionOfKing(forPosition position: Position,
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
  
  /// Finds the position of the first piece that can move to the
  /// input position.
  ///
  /// This method is useful when converting from an algebraic notation
  /// to a move because for example:
  /// - "a4" we know that only one pawn can move to a4; even if
  /// there's two pawns, a white one on a3 and a black one on a5, we
  /// know which pawn moved to a4 based on who's turn it is
  /// - "Nc6" there's only one knight that can move to c6, otherwise
  /// the notation would be different
  ///
  /// - Parameters:
  ///   - ofPiece: the piece we're expecting to find
  ///   - thatCanMoveTo: the destination where the input piece
  ///   should be able to move to
  ///
  /// - Returns: The position of the input piece that can move to
  /// the destination.
  private static func findPosition(ofPiece expectedPiece: Piece,
                                   onBoard board: [[SquareState]],
                                   boardSettings: BoardSettings,
                                   thatCanMoveTo destination: Position) -> Position?
  {
    /// We need to check all squares for pieces that fit the descri
    for (row, boardRow) in board.enumerated() {
      for (column, _) in boardRow.enumerated() {
        if let position = Position(row: row, column: column),
           check(ifPiece: expectedPiece,
                 atPosition: position,
                 canMoveTo: destination,
                 onBoard: board,
                 boardSettings: boardSettings)
        {
          return position
        }
      }
    }
    return nil
  }
  /// Finds the position of the first piece that can move to the
  /// input position.
  ///
  /// This method is useful when converting from an algebraic notation
  /// to a move because for example:
  /// - "a4" we know that only one pawn can move to a4; even if
  /// there's two pawns, a white one on a3 and a black one on a5, we
  /// know which pawn moved to a4 based on who's turn it is
  /// - "Nc6" there's only one knight that can move to c6, otherwise
  /// the notation would be different.
  ///
  /// - Parameters:
  ///   - ofPiece: the piece we're expecting to find based on
  ///   notation
  ///   - thatCanMoveTo: the destination where the input piece
  ///   should be able to move to
  ///
  /// - Returns: The position of the input piece that can move to
  /// the destination.
  private static func findPosition(ofPiece expectedPiece: Piece,
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
    
    for (index, _) in boardSlice.enumerated() {
      if let position = Position(row: rank?.rawValue ?? index, column: file?.rawValue ?? index),
         check(ifPiece: expectedPiece,
               atPosition: position,
               canMoveTo: destination,
               onBoard: board,
               boardSettings: boardSettings)
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
  
  private static func findSamePieces(as inputPiece: Piece,
                                     side inputSide: Side,
                                     from inputPosition: Position,
                                     thatCanMoveTo inputDestination: Position,
                                     onBoard board: [[SquareState]],
                                     boardSettings: BoardSettings) -> (Bool, Bool)
  {
    var sameRank: Bool = false
    var sameFile: Bool = false
    
    for (row, squareRow) in board.enumerated() {
      for (column, squareState) in squareRow.enumerated() {
        guard let position = Position(row: row, column: column) else {
          fatalError("We're traversing the board. Position should be valid. row = \(row) column = \(column)")
        }
        switch squareState {
          case .empty:
            break
          case .occupied(let piece, let side):
            guard piece == inputPiece &&
                    side == inputSide &&
                    position != inputPosition else
            {
              break
            }
              
            let legalDestinations = calculateLegalDestinations(forPieceAtPosition: position,
                                                               onBoard: board,
                                                               boardSettings: boardSettings)
            if legalDestinations.contains(inputDestination) {
              if position.rank == inputPosition.rank {
                sameRank = true
              } else if position.file == inputPosition.file {
                sameFile = true
              } else {
                fatalError("Either rank or file should be the same. What case is this?")
              }
            }
        }
      }
    }
    
    return (sameRank, sameFile)
  }
  
  private static func calculateTheoreticalDestinations(forPieceAtPosition position: Position,
                                                       isKingInCheck: Bool,
                                                       onBoard board: [[SquareState]],
                                                       boardSettings: BoardSettings) -> [[Position]]
  {
    guard case .occupied(let piece, let side) = board[position.row][position.column] else {
      return []
    }
    
    var result: [[Position]] = []
    var currentMoves: [Position] = []
    
    let pinnedDirections = calculatePinnedDirections(forPieceAtPosition: position,
                                                     onBoard: board,
                                                     turn: side)
    
    switch piece {
      case .bishop:
        let directions = filterDirections([.bottomLeft, .bottomRight, .topLeft, .topRight],
                                          withPinnedDirections: pinnedDirections)
        result = generateTheoreticalDestinations(forDirections: directions,
                                                 fromPosition: position)
      case .king:
        /// King can never be pinned.
        for direction in Direction.allCases {
          if let newPosition = position.next(inDirection: direction),
             isPositionUnderAttack(newPosition, onBoard: board, boardSettings: boardSettings) == false
          {
            result.append([newPosition])
          }
        }
        
        if isKingInCheck == false {
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
            advanceDirection = filterDirections([.down],
                                                withPinnedDirections: pinnedDirections).first
            captureDirections = filterDirections([.bottomLeft, .bottomRight],
                                                  withPinnedDirections: pinnedDirections)
          case .white:
            advanceDirection = filterDirections([.up],
                                                withPinnedDirections: pinnedDirections).first
            captureDirections = filterDirections([.topLeft, .topRight],
                                                 withPinnedDirections: pinnedDirections)
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
        let directions = filterDirections(Direction.allCases,
                                          withPinnedDirections: pinnedDirections)
        result = generateTheoreticalDestinations(forDirections: directions,
                                                 fromPosition: position)
      case .rook:
        let directions = filterDirections([.down, .left, .right, .up],
                                          withPinnedDirections: pinnedDirections)
        result = generateTheoreticalDestinations(forDirections: directions,
                                                 fromPosition: position)
    }
    
    return result
  }
  
  private static func generateTheoreticalDestinations(forDirections directions: [Direction],
                                                      fromPosition: Position) -> [[Position]] {
    var result: [[Position]] = []
    var currentDestinations: [Position] = []
    
    for direction in directions {
      var referencePosition = fromPosition
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
    return findEnemiesAttackingPosition(position, onBoard: board, boardSettings: boardSettings).isNonEmpty
  }
  
  /// This method finds all positions of enemy pieces
  /// that are attacking the particular square. The
  /// targeted square could be empty.
  ///
  /// - Parameters:
  ///   - atPosition: Position of the square being attacked.
  /// - Returns: An array of positions for all pieces that
  /// have the targeted square as a legal destionation.
  private static func findEnemiesAttackingPosition(_ position: Position,
                                                   onBoard board: [[SquareState]],
                                                   boardSettings: BoardSettings) -> [Position]
  {
    var enemyPositions: [Position] = []
    
    for (row, boardRow) in board.enumerated() {
      for (column, squareState) in boardRow.enumerated() {
        switch squareState {
          case .empty:
            break
          case .occupied(let piece, let side):
            /// A king can't put the other king in check.
            guard piece != .king && side != boardSettings.turn else {
              break
            }
            if let enemyPosition = Position(row: row, column: column) {
              let legalDestinations = calculateLegalDestinations(forPieceAtPosition: enemyPosition,
                                                                 onBoard: board,
                                                                 boardSettings: boardSettings)
              if legalDestinations.contains(position) {
                enemyPositions.append(enemyPosition)
              }
            }
        }
      }
    }
    
    return enemyPositions
  }
  
  /// This method finds all the directions on which the piece at the
  /// input position is pinned.
  ///
  /// When talking in the code about "pinned piece", we're only
  /// talking about a piece being pinned to the king.
  /// If a piece is pinned, it's pinned in at least 2 directions
  /// (up and down, top left and bottom right, etc), but it can also
  /// be pinned by multiple pieces, e.g: a rook on up/down and a
  /// bishop on top left / bottom right
  ///
  /// - Parameters:
  ///   - forPieceAtPosition: Position of the piece for which we
  ///   are calculating the directions on which it is pinned.
  ///
  /// - Returns: An array of directions on which the inputted piece
  /// is pinned.
  static private func calculatePinnedDirections(forPieceAtPosition position: Position,
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
