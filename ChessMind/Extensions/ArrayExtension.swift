//
// The ChessMind project.
// Created by optionaldev on 10/11/2024.
// Copyright © 2024 optionaldev. All rights reserved.
// 

extension Array {
  
  var isNonEmpty: Bool {
    return !isEmpty
  }
  
  func element(at index: Int) -> Element? {
    if index < count {
      return self[index]
    }
    
    return nil
  }
}
