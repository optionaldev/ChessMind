//
// The ChessMind project.
// Created by optionaldev on 21/12/2024.
// Copyright © 2024 optionaldev. All rights reserved.
// 

import UIKit

final class OpeningCell: UICollectionViewCell {
  
  func configure(text: String) {
    label.text = text
  }
  
  // MARK: Init
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    // Maybe also add an icon for the opening, something representative.
    
    let label = CustomLabel()
    
    contentView.addSubview(label)
    contentView.backgroundColor = UIColor.darkSquareColor
    
    NSLayoutConstraint.activate([
      label.centerXAnchor.constraint(equalTo: centerXAnchor),
      label.centerYAnchor.constraint(equalTo: centerYAnchor)
    ])
    
    self.label = label
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Private
  
  private weak var label: CustomLabel!
}
