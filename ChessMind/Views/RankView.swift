//
// The ChessMind project.
// Created by optionaldev on 25/10/2024.
// Copyright © 2024 optionaldev. All rights reserved.
// 

import UIKit

final class RankView: UIView {
  
  private(set) var eightSquares: [SquareView] = []
  
  func configure(withRankContent rankContent: [SquareState]) {
    for (index, squareState) in rankContent.enumerated() {
      eightSquares[index].configure(squareState: squareState, shouldHideUntilAnimationFinishes: false)
    }
  }
  
  // MARK: Init
  
  init(rank: Rank) {
    let startingWithWhiteSquare = rank.rawValue % 2 == 1
    super.init(frame: .zero)
    
    for (index, file) in File.allCases.enumerated() {
      let background: UIColor
      if (startingWithWhiteSquare && file.rawValue % 2 == 0) ||
          (startingWithWhiteSquare == false && file.rawValue % 2 == 1)
      {
        background = .lightSquareColor
      } else {
        background = .darkSquareColor
      }
      
      let squareView = SquareView(background: background, position: .init(rank: rank, file: file))
      addSubview(squareView)
      
      NSLayoutConstraint.activate([
        squareView.leftAnchor.constraint(equalTo: leftAnchor,
                                         constant: Constants.squareSize * CGFloat(index)),
        squareView.topAnchor.constraint(equalTo: topAnchor)
      ])
      
      eightSquares.append(squareView)
    }
    
    translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      widthAnchor.constraint(equalToConstant: Screen.width),
      heightAnchor.constraint(equalToConstant: Constants.squareSize)
    ])
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
}
