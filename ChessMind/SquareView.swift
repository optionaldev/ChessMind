//
// The ChessMind project.
// Created by optionaldev on 25/10/2024.
// Copyright © 2024 optionaldev. All rights reserved.
// 

import UIKit

final class SquareView: UIView {
  
  func configure(square: Square) {
    if let imageName = square.imageName {
      pieceImageView.image = UIImage(named: imageName)
      pieceImageView.isHidden = false
      squareLabel.isHidden = true
    } else {
      pieceImageView.isHidden = true
      squareLabel.isHidden = false
    }
  }
  
  func highlight() {
    if background == .whiteSquareColor {
      backgroundColor = .whiteHighlitedSquareColor
    } else {
      backgroundColor = .blackHighlitedSquareColor
    }
  }
  
  func unhilight() {
    backgroundColor = background
  }
  
  // MARK: Init
  
  init(background: UIColor, position: String) {
    self.background = background
    
    super.init(frame: .zero)
    
    let pieceImageView = UIImageView()
    pieceImageView.translatesAutoresizingMaskIntoConstraints = false
    
    let squareLabel = UILabel()
    squareLabel.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
    squareLabel.font = UIFont(name: "Helvetica Neue", size: 13)
    squareLabel.text = position
    squareLabel.translatesAutoresizingMaskIntoConstraints = false
    
    addSubview(pieceImageView)
    addSubview(squareLabel)
    backgroundColor = background
    translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint.activate([
      pieceImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
      pieceImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
      pieceImageView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.8),
      pieceImageView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.8),
      
      squareLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
      squareLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
      
      widthAnchor.constraint(equalToConstant: Constants.squareSize),
      heightAnchor.constraint(equalToConstant: Constants.squareSize)
    ])
    
    self.pieceImageView = pieceImageView
    self.squareLabel = squareLabel
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Private
  
  private let background: UIColor
  
  private weak var pieceImageView: UIImageView!
  private weak var squareLabel: UILabel!
}
