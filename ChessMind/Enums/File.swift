//
// The ChessMind project.
// Created by optionaldev on 08/11/2024.
// Copyright © 2024 optionaldev. All rights reserved.
// 

enum File: Int, CaseIterable {
  
  case a
  case b
  case c
  case d
  case e
  case f
  case g
  case h
  
  var notation: Character {
    switch self {
      case .a:
        return "a"
      case .b:
        return "b"
      case .c:
        return "c"
      case .d:
        return "d"
      case .e:
        return "e"
      case .f:
        return "f"
      case .g:
        return "g"
      case .h:
        return "h"
    }
  }
  
  func offsetBy(n: Int) -> File {
    return File(rawValue: rawValue + n)!
  }
  
  // MARK: Init
  
  init?(character: Character) {
    if let file = File.allCases.first(where: { $0.notation == character }) {
      self = file
    }
    return nil
  }
}
