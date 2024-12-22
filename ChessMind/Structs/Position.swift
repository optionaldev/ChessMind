//
// The ChessMind project.
// Created by optionaldev on 25/10/2024.
// Copyright © 2024 optionaldev. All rights reserved.
//

import UIKit

struct Position: Equatable, CustomStringConvertible {
  
  let row: Int    /// Used to represent ranks
  let column: Int /// Used to represent files

  func next(inDirection direction: Direction) -> Position? {
    switch direction {
      case .up:
        return Position(row: row + 1, column: column)
      case .down:
        return Position(row: row - 1, column: column)
      case .left:
        return Position(row: row, column: column - 1)
      case .right:
        return Position(row: row, column: column + 1)
      case .topRight:
        return Position(row: row + 1, column: column + 1)
      case .topLeft:
        return Position(row: row + 1, column: column - 1)
      case .bottomRight:
        return Position(row: row - 1, column: column + 1)
      case .bottomLeft:
        return Position(row: row - 1, column: column - 1)
    }
  }
  
  func next(inDirection direction: KnightDirection) -> Position? {
    switch direction {
      case .downLeft:
        return Position(row: row - 2, column: column - 1)
      case .downRight:
        return Position(row: row - 2, column: column + 1)
      case .leftDown:
        return Position(row: row - 1, column: column - 2)
      case .leftUp:
        return Position(row: row + 1, column: column - 2)
      case .rightDown:
        return Position(row: row - 1, column: column + 2)
      case .rightUp:
        return Position(row: row + 1, column: column + 2)
      case .upLeft:
        return Position(row: row + 2, column: column - 1)
      case .upRight:
        return Position(row: row + 2, column: column + 1)
    }
  }
  
  func frame(isBoardFlipped boardFlipped: Bool, verticalOffset: CGFloat) -> CGRect {
    let xMultiplier = CGFloat(boardFlipped ? Constants.boardLength - column - 1 : column)
    let yMultiplier = CGFloat(boardFlipped ? row : Constants.boardLength - row - 1)
    
    let offset = (Constants.squareSize - Constants.pieceImageSize) / 2
    
    return CGRect(x: xMultiplier * Constants.squareSize + offset,
                  y: yMultiplier * Constants.squareSize + offset + verticalOffset,
                  width: Constants.pieceImageSize,
                  height: Constants.pieceImageSize)
  }
  
  // MARK: Init
  
  init(rank: Rank, file: File) {
    row = rank.rawValue
    column = file.rawValue
  }
  
  /// Initialize a position from a row and column.
  ///
  /// The reason it's a failable initializer is
  /// because we want be able to travel from a
  /// position into a certaion direction until
  /// position is no longer within the board,
  /// which is much better than always checking
  /// if we're at the edge for both rank and file.
  init?(row: Int, column: Int) {
    guard row >= 0 && row < 8 && column >= 0 && column < 8 else {
      return nil
    }
    
    self.row = row
    self.column = column
  }
  
  init?(notation: String) {
    guard notation.count == 2,
          let fileCharacter = notation.first,
          let rankCharacter = notation.last,
          let file = File(character: fileCharacter),
          let rank = Rank(character: rankCharacter)
    else
    {
      return nil
    }
    
    self.row = rank.rawValue
    self.column = file.rawValue
  }
  
  /// Rank is row, but in a chess representation
  /// values from 1 to 8
  var rank: Rank {
    return Rank(rawValue: row)!
  }
  
  var file: File {
    return File(rawValue: column)!
  }
  
  var notation: String {
    return "\(file.notation)\(rank.notation)"
  }
  
  // MARK: CustomStrinConvertible conformance
  
  var description: String {
    return notation
  }
}
