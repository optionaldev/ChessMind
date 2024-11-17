//
// The ChessMind project.
// Created by optionaldev on 10/11/2024.
// Copyright © 2024 optionaldev. All rights reserved.
// 

struct CastlingSide: OptionSet {
  
  let rawValue: Int
  
  static let kingSide  = Self(rawValue: 1 << 0)
  static let queenSide = Self(rawValue: 1 << 1)
}

