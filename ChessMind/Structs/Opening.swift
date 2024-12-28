//
// The ChessMind project.
// Created by optionaldev on 21/12/2024.
// Copyright © 2024 optionaldev. All rights reserved.
// 

struct Opening: Decodable {
  
  let name: String
  let lines: [Line]
  
  var temporaryFileName: String {
    return "\(name.lowercased()).json"
  }
}
