//
// The ChessMind project.
// Created by optionaldev on 25/10/2024.
// Copyright © 2024 optionaldev. All rights reserved.
// 

import UIKit

final class SquareView: UIView {
  
  func configure(square: Square) {
    pieceImageView.image = UIImage(named: square.imageName)
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
  
  init(background: UIColor) {
    self.background = background
    
    super.init(frame: .zero)
    
    let pieceImageView = UIImageView()
    pieceImageView.translatesAutoresizingMaskIntoConstraints = false
    
    addSubview(pieceImageView)
    backgroundColor = background
    translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint.activate([
      pieceImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
      pieceImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
      pieceImageView.widthAnchor.constraint(equalTo: widthAnchor),
      pieceImageView.heightAnchor.constraint(equalTo: heightAnchor),
      
      widthAnchor.constraint(equalToConstant: Constants.squareSize),
      heightAnchor.constraint(equalToConstant: Constants.squareSize)
    ])
    
    self.pieceImageView = pieceImageView
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Private
  
  private let background: UIColor
  
  private weak var pieceImageView: UIImageView!
}
