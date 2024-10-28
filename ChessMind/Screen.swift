//
// The ChessMemo project.
// Created by optionaldev on 25/10/2024.
// Copyright © 2024 optionaldev. All rights reserved.
// 

import UIKit

/// Made enum since we're not meant to declare
/// instances of this.
enum Screen {
  
  static var width: CGFloat {
    return UIScreen.main.bounds.width
  }
  
  static var height: CGFloat {
    return UIScreen.main.bounds.height
  }
}
