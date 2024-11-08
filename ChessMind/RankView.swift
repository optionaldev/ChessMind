//
// The ChessMind project.
// Created by optionaldev on 25/10/2024.
// Copyright © 2024 optionaldev. All rights reserved.
// 

import UIKit

protocol BoardDelegate: AnyObject {
  
}

final class RankView: UIView {
  
  weak var delegate: BoardDelegate?
  
  private(set) var eightSquares: [SquareView] = []
  
  func configure(withRank rank: [Square]) {
    for (index, square) in rank.enumerated() {
      eightSquares[index].configure(square: square)
    }
  }
  
  func highlight(item: Int) {
    eightSquares[item].highlight()
  }
  
  func unhilight(item: Int) {
    eightSquares[item].unhilight()
  }
  
  // MARK: Init
  
  init(rank: Int) {
    let startingWithWhiteSquare = rank % 2 == 0
    super.init(frame: .zero)
    
    for index in 0..<Constants.boardLength {
      let background: UIColor
      if (startingWithWhiteSquare && index % 2 == 0) ||
          (startingWithWhiteSquare == false && index % 2 == 1)
      {
        background = .whiteSquareColor
      } else {
        background = .blackSquareColor
      }
      
      let squareView = SquareView(background: background, position: "\(File.forIndex(index: index))\(Constants.boardLength - rank)")
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
