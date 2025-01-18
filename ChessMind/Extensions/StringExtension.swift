//
// The ChessMind project.
// Created by optionaldev on 21/12/2024.
// Copyright © 2024 optionaldev. All rights reserved.
// 

import Foundation
import UIKit

extension String {
  
  var isNonEmpty: Bool {
    return !isEmpty
  }
  
  func attributed(color: UIColor) -> NSAttributedString {
    return NSAttributedString(string: self, attributes: [.foregroundColor : color])
  }
}
