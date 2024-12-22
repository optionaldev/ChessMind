//
// The ChessMind project.
// Created by optionaldev on 22/12/2024.
// Copyright © 2024 optionaldev. All rights reserved.
// 

import UIKit

final class LineCell: UICollectionViewCell {
  
  func configure(text: String?) {
    nameLabel.text = text
  }
  
  // MARK: Init
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    let nameLabel = CustomLabel(fontSize: Constants.lineLabelFontSize)
    
    backgroundColor = UIColor.lightSquareColor
    contentView.addSubview(nameLabel)
    
    NSLayoutConstraint.activate([
      nameLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
      nameLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
    ])
    
    self.nameLabel = nameLabel
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Private
  
  private weak var nameLabel: CustomLabel!
}
