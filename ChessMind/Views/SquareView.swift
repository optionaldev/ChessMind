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
  
  func highlight(type highlightType: HighlightType) {
    switch highlightType {
      case .canMove:
        highlightCanMove()
      case .kingIsInCheck:
        highlightKingIsInCheck()
      case .isSelected:
        highlightIsSelected()
      case .previousMove(let type):
        createPreviousMoveTriangleIfNeeded()
        switch type {
          case .from:
            previousMoveLayer?.fillColor = UIColor.systemPink.cgColor
          case .to:
            previousMoveLayer?.fillColor = UIColor.purple.cgColor
        }
        previousMoveLayer?.isHidden = false
    }
  }
  
  func unhilight(type unhighlightType: HighlightType) {
    switch unhighlightType {
      case .canMove:
        layer.borderWidth = 0
      case .kingIsInCheck:
        kingIsInCheckLayer?.isHidden = true
      case .isSelected:
        backgroundColor = background
      case .previousMove:
        previousMoveLayer?.isHidden = true
    }
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
  
  private weak var kingIsInCheckLayer: CAGradientLayer?
  private weak var pieceImageView: UIImageView!
  private weak var previousMoveLayer: CAShapeLayer?
  private weak var squareLabel: UILabel!
  
  private func createPreviousMoveTriangleIfNeeded() {
    if previousMoveLayer == nil {
      let trianglePath = UIBezierPath()
      trianglePath.move(to: CGPoint(x: bounds.width, y: 0))
      trianglePath.addLine(to: .init(x: bounds.width, y: Constants.previousMoveImageSize))
      trianglePath.addLine(to: .init(x: bounds.width - Constants.previousMoveImageSize, y: 0))
      trianglePath.close()
      
      let triangleLayer = CAShapeLayer()
      triangleLayer.path = trianglePath.cgPath
      triangleLayer.fillColor = UIColor.systemPink.cgColor
      
      layer.addSublayer(triangleLayer)
      
      self.previousMoveLayer = triangleLayer
    }
  }
  
  private func highlightCanMove() {
    layer.borderColor = UIColor.red.cgColor
    layer.borderWidth = 5
  }
  
  private func highlightKingIsInCheck() {
    if kingIsInCheckLayer == nil {
      let kingIsInCheckLayer = CAGradientLayer()
      kingIsInCheckLayer.frame = bounds
      kingIsInCheckLayer.type = .radial
      kingIsInCheckLayer.colors = [ UIColor.red.cgColor,
                               UIColor.red.cgColor,
                               UIColor.clear.cgColor]
      kingIsInCheckLayer.locations = [0, 0.5, 1]
      kingIsInCheckLayer.startPoint = CGPoint(x: 0.5, y: 0.5)
      kingIsInCheckLayer.endPoint = CGPoint(x: 1, y: 1)
      layer.addSublayer(kingIsInCheckLayer)
      
      bringSubviewToFront(pieceImageView)
      
      self.kingIsInCheckLayer = kingIsInCheckLayer
    }
    
    kingIsInCheckLayer?.isHidden = false
  }
  
  private func highlightIsSelected() {
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
}
