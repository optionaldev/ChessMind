//
// The ChessMind project.
// Created by optionaldev on 09/11/2024.
// Copyright © 2024 optionaldev. All rights reserved.
// 

enum Rank: Int, CaseIterable {
  
  case first
  case second
  case third
  case fourth
  case fifth
  case sixth
  case seventh
  case eighth
  
  var notation: String {
    return "\(rawValue + 1)"
  }
}
