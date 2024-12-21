//
// The ChessMind project.
// Created by optionaldev on 21/12/2024.
// Copyright © 2024 optionaldev. All rights reserved.
// 

import UIKit

final class CustomLabel: UILabel {
  
  // MARK: Init
  
  init() {
    super.init(frame: .zero)
    
    font = UIFont(name: "Helvetica", size: 30)
    
    translatesAutoresizingMaskIntoConstraints = false
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
