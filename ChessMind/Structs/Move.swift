//
// The ChessMind project.
// Created by optionaldev on 25/10/2024.
// Copyright © 2024 optionaldev. All rights reserved.
// 

struct Move: CustomStringConvertible {
  
  let from: Position
  let to: Position
  
  init(from: Position, to: Position) {
    self.from = from
    self.to = to
  }
  
  // MARK: CustomStringConvertible conformance
  
  var description: String {
    return "Move(\(from) -> \(to))"
  }
}
