//
// The ChessMind project.
// Created by optionaldev on 25/10/2024.
// Copyright © 2024 optionaldev. All rights reserved.
// 

import UIKit

final class SquareView: UIView {
  
  let position: Position
  
  private(set) var squareState: SquareState
  
  func configure(squareState: SquareState) {
    self.squareState = squareState
    
    if let imageName = squareState.imageName {
      pieceImageView.image = UIImage(named: imageName)
      pieceImageView.isHidden = false
      squareLabel.isHidden = true
    } else {
      pieceImageView.isHidden = true
      squareLabel.isHidden = false
    }
  }
  
  func handleNewOrientation(_ flipped: Bool) {
    let transform: CGAffineTransform = flipped ? .init(rotationAngle: .pi) : .identity
    
    pieceImageView.transform = transform
    squareLabel.transform = transform
  }
  
  func highlight() {
    switch squareState {
      case .empty:
        return
      case .occupied:
        if background == .whiteSquareColor {
          backgroundColor = .whiteHighlitedSquareColor
        } else {
          backgroundColor = .blackHighlitedSquareColor
        }
    }
  }
  
  func markRed() {
    if gradientLayer == nil {
      let gradientLayer = CAGradientLayer()
      gradientLayer.frame = bounds
      gradientLayer.type = .radial
      gradientLayer.colors = [ UIColor.red.cgColor,
                               UIColor.red.cgColor,
                               UIColor.clear.cgColor]
      gradientLayer.locations = [0, 0.5, 1]
      gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.5)
      gradientLayer.endPoint = CGPoint(x: 1, y: 1)
      layer.addSublayer(gradientLayer)
      
      bringSubviewToFront(pieceImageView)
      
      self.gradientLayer = gradientLayer
    }
    
    gradientLayer?.isHidden = false
  }
  
  func markRedIfHasKing(sideInCheck: Side) {
    if case .occupied(let piece, let side) = squareState {
      if piece == .king && sideInCheck == side {
        markRed()
      }
    }
  }
  
  func unhilight() {
    switch squareState {
      case .empty:
        return
      case .occupied:
        backgroundColor = background
    }
  }
  
  func unmarkRed() {
    gradientLayer?.isHidden = true
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    
    gradientLayer?.frame = bounds
  }
  
  // MARK: Init
  
  init(background: UIColor, position: Position) {
    self.background = background
    self.position = position
    self.squareState = .empty
    
    super.init(frame: .zero)
    
    let pieceImageView = UIImageView()
    pieceImageView.translatesAutoresizingMaskIntoConstraints = false
    
    let squareLabel = UILabel()
    squareLabel.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
    squareLabel.font = UIFont(name: "Helvetica Neue", size: 13)
    squareLabel.text = position.notation
    squareLabel.translatesAutoresizingMaskIntoConstraints = false
    
    addSubview(pieceImageView)
    addSubview(squareLabel)
    backgroundColor = background
    translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint.activate([
      pieceImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
      pieceImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
      pieceImageView.widthAnchor.constraint(equalToConstant: Constants.imageSize),
      pieceImageView.heightAnchor.constraint(equalToConstant: Constants.imageSize),
      
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
  private weak var gradientLayer: CAGradientLayer?
}
