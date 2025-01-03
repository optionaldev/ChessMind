//
// The ChessMind project.
// Created by optionaldev on 09/11/2024.
// Copyright © 2024 optionaldev. All rights reserved.
// 

enum Rank: Int, CaseIterable, Strideable {
  
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
  
  func offsetBy(n: Int) -> Rank {
    return Rank(rawValue: rawValue + n)!
  }
  
  // MARK: Init
  
  init?(character: Character) {
    if let intValue = Int(character),
       /// We subtract one because notation is from 1 to 8
       let rank = Rank(rawValue: intValue - 1)
    {
      self = rank
    } else {
      return nil
    }
  }
  
  // MARK: Strideable conformance
  
  func distance(to other: Rank) -> Int {
    return other.rawValue - rawValue
  }
  
  func advanced(by n: Int) -> Rank {
    return Rank(rawValue: rawValue + n)!
  }
}
