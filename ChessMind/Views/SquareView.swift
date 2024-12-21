//
// The ChessMind project.
// Created by optionaldev on 25/10/2024.
// Copyright © 2024 optionaldev. All rights reserved.
// 

import UIKit

final class SquareView: UIView {
  
  let position: Position
  
  private(set) var squareState: SquareState
  
  func configure(squareState: SquareState, shouldHideUntilAnimationFinishes: Bool) {
    self.squareState = squareState
    
    if let imageName = squareState.imageName {
      pieceImageView.image = UIImage(named: imageName)
      pieceImageView.isHidden = shouldHideUntilAnimationFinishes
      squareLabel.isHidden = true
    } else {
      pieceImageView.isHidden = true
      squareLabel.isHidden = false
    }
  }
  
  func show() {
    pieceImageView.isHidden = false
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
  
  func unhighlight(type unhighlightType: HighlightType) {
    switch unhighlightType {
      case .canMove:
        canMoveImageView?.alpha = 0
        canMoveImageView?.isHidden = true
        canMovePulseTimer?.invalidate()
        canMovePulseTimer = nil
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
    squareLabel.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2)
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
  
  // MARK: Overrides
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    kingIsInCheckLayer?.frame = bounds
  }
  
  // MARK: - Private
  
  private let background: UIColor
  
  private var canMovePulseTimer: Timer?
  
  private weak var canMoveImageView: UIImageView?
  private weak var kingIsInCheckLayer: CAGradientLayer?
  private weak var pieceImageView: UIImageView!
  private weak var previousMoveLayer: CAShapeLayer?
  private weak var squareLabel: UILabel!
  
  private var canMoveStartingColor: CGColor {
    return background == UIColor.lightSquareColor ? UIColor(red: 200, green: 60, blue: 200).cgColor : UIColor(red: 0, green: 0, blue: 0).cgColor
  }
  
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
      triangleLayer.zPosition = 5
      
      layer.addSublayer(triangleLayer)
      
      self.previousMoveLayer = triangleLayer
    }
  }
  
  private func highlightCanMove() {
    if canMoveImageView == nil {
      let imageName = background == UIColor.lightSquareColor ? "frame_white" : "frame_black"
      let canMoveImageView = UIImageView(image: UIImage(named: imageName))
      canMoveImageView.translatesAutoresizingMaskIntoConstraints = false
      canMoveImageView.alpha = 0
      
      addSubview(canMoveImageView)
      
      NSLayoutConstraint.activate([
        canMoveImageView.topAnchor.constraint(equalTo: topAnchor),
        canMoveImageView.leftAnchor.constraint(equalTo: leftAnchor),
        canMoveImageView.rightAnchor.constraint(equalTo: rightAnchor),
        canMoveImageView.bottomAnchor.constraint(equalTo: bottomAnchor),
      ])
      
      self.canMoveImageView = canMoveImageView
    }
    
    UIView.animate(withDuration: 0.2) { [weak self] in
      self?.canMoveImageView?.alpha = 1
    }
    canMoveImageView?.isHidden = false
    
    canMovePulseTimer = Timer.scheduledTimer(withTimeInterval: 8, repeats: true) { _ in
      UIView.animate(withDuration: 0.6, animations: { [weak self] in
        self?.canMoveImageView?.alpha = 0.4
        
      }, completion: { _ in
        UIView.animate(withDuration: 0.6) { [weak self] in
          self?.canMoveImageView?.alpha = 1
        }
      })
    }
  }
  
  private func highlightKingIsInCheck() {
    if kingIsInCheckLayer == nil {
      let kingIsInCheckLayer = CAGradientLayer()
      kingIsInCheckLayer.type = .radial
      kingIsInCheckLayer.colors = [UIColor.red.cgColor,
                                   UIColor.red.cgColor,
                                   UIColor.red.withAlphaComponent(0.1).cgColor]
      kingIsInCheckLayer.locations = [0, 0.4, 1]
      kingIsInCheckLayer.startPoint = CGPoint(x: 0.5, y: 0.5)
      kingIsInCheckLayer.endPoint = CGPoint(x: 1, y: 1)
      layer.addSublayer(kingIsInCheckLayer)
      
      [pieceImageView, squareLabel, canMoveImageView].compactMap { $0 }
        .forEach { bringSubviewToFront($0) }
      
      self.kingIsInCheckLayer = kingIsInCheckLayer
    }
    
    kingIsInCheckLayer?.isHidden = false
  }
  
  private func highlightIsSelected() {
    switch squareState {
      case .empty:
        return
      case .occupied:
        if background == .lightSquareColor {
          backgroundColor = .lightHighlitedSquareColor
        } else {
          backgroundColor = .darkHighlitedSquareColor
        }
    }
  }
}
