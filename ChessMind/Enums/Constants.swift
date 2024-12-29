//
// The ChessMind project.
// Created by optionaldev on 25/10/2024.
// Copyright © 2024 optionaldev. All rights reserved.
// 

import UIKit

enum Constants {
  
  /// How many squares a chess board has in both width and height.
  /// Since the board is a square, only one value is needed.
  static let boardLength = 8
  
  /// Algebraic notation for a piece capturing another piece.
  static let captureNotation: Character = "x"
  
  /// Algebraic notation for castling long.
  static let castlingLongNotation = "O-O-O"
  
  /// Algebraic notation for castling short.
  static let castlingShortNotation = "O-O"
  
  /// FEN notation is split into several components separated by a
  /// space. If a component is empty, it is represented as a dash.
  static let fenEmptyField = "-"
  
  /// Font size of the label in the LineCell
  static let lineLabelFontSize: CGFloat = 24
  
  /// Spacing between top / bottom and the label in the LineCell.
  static let lineLabelPadding: CGFloat = 8
  
  /// Spacing between top / bottom and the label in the LineCell.
  static let lineCollectionSpacing: CGFloat = 5
  
  /// Font size of the main label in the OpeningCell.
  static let openingLabelFontSize: CGFloat = 30
  
  /// Spacing between top / bottom and the main label in the
  /// OpeningCell. We want it to look centered without having to
  /// set center constraints.
  static let openingLabelPadding: CGFloat = 10
  
  /// How big the image for a piece inside a square should be relative
  /// to the square itself.
  static let pieceImageSize: CGFloat = squareSize * 0.8
  
  /// How big should the sides of the triangle that represents the
  /// previous move should be (not including hypotenuse).
  static let previousMoveImageSize: CGFloat = squareSize * 0.37
  
  /// How big is a chess square, based on screen size
  static let squareSize: CGFloat = Screen.width / CGFloat(boardLength)
}
