//
// The ChessMind project.
// Created by optionaldev on 17/11/2024.
// Copyright © 2024 optionaldev. All rights reserved.
// 

extension Int {
  
  init?(_ character: Character) {
    if let value = Int(String(character)) {
      self = value
    }
    return nil
  }
}
