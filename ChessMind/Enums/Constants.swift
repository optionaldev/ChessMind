//
// The ChessMind project.
// Created by optionaldev on 25/10/2024.
// Copyright © 2024 optionaldev. All rights reserved.
// 

import UIKit

enum Constants {
  
  static let boardLength = 8
  static let boardTopOffset: CGFloat = 50
  static let fenEmptyField = "-"
  static let imageSize: CGFloat = squareSize * 0.8
  static let longCastlingNotation = "O-O-O"
  static let previousMoveImageSize: CGFloat = squareSize * 0.37
  static let shortCastlingNotation = "O-O"
  static let squareSize: CGFloat = Screen.width / CGFloat(boardLength)
}
