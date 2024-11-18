//
// The ChessMind project.
// Created by optionaldev on 17/11/2024.
// Copyright © 2024 optionaldev. All rights reserved.
// 

extension Int {
  
  init?(_ character: Character) {
    print("Trying to create int from character = \(character) str = \(String(character)) int = \(Int(String(character)))")
    if let value = Int(String(character)) {
      self = value
    } else {
      return nil
    }
  }
}
