//
// The ChessMind project.
// Created by optionaldev on 09/11/2024.
// Copyright © 2024 optionaldev. All rights reserved.
//

typealias Turn = Side

enum Side: String {
  
  case black
  case white
  
  mutating func toggle() {
    if self == .black {
      self = .white
    } else {
      self = .black
    }
  }
}
