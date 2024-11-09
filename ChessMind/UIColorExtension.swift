//
// The ChessMind project.
// Created by optionaldev on 25/10/2024.
// Copyright © 2024 optionaldev. All rights reserved.
// 

import UIKit

extension UIColor {
  
  convenience init(red: Int, green: Int, blue: Int, alpha: CGFloat = 1) {
    self.init(red: CGFloat(red) / CGFloat(256),
              green: CGFloat(green) / CGFloat(256),
              blue: CGFloat(blue) / CGFloat(256),
              alpha: alpha)
  }
  
  static let blackSquareColor = UIColor(red: 0, green: 140, blue: 0)
  static let blackHighlitedSquareColor = UIColor(red: 244, green: 187, blue: 68)
  
  static let whiteSquareColor = UIColor(red: 240, green: 240, blue: 240)
  static let whiteHighlitedSquareColor = UIColor(red: 255, green: 234, blue: 0)
}
