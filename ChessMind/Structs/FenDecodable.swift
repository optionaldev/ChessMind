//
// The ChessMind project.
// Created by optionaldev on 25/10/2024.
// Copyright © 2024 optionaldev. All rights reserved.
// 

struct FenDecodable: Decodable {
  
  let fens: [String: FenEntryDecodable]
}

struct FenEntryDecodable: Decodable {
  
  let bestMove: String
  let otherCandidates: [String]?
  let blunders: [String]?
}
