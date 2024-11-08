//
// The ChessMind project.
// Created by optionaldev on 08/11/2024.
// Copyright © 2024 optionaldev. All rights reserved.
// 

enum File {
  
  static func forIndex(index: Int) -> String {
    switch index {
      case 0: return "a"
      case 1: return "b"
      case 2: return "c"
      case 3: return "d"
      case 4: return "e"
      case 5: return "f"
      case 6: return "g"
      case 7: return "h"
      default:
        fatalError()
    }
  }
}
