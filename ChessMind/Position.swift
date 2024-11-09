//
// The ChessMind project.
// Created by optionaldev on 25/10/2024.
// Copyright © 2024 optionaldev. All rights reserved.
// 

struct Position: Equatable, CustomStringConvertible {
  
  let row: Int
  let column: Int
  
  init(rank: Rank, file: File) {
    row = rank.rawValue
    column = file.rawValue
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
