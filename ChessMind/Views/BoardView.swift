//
// The ChessMind project.
// Created by optionaldev on 25/10/2024.
// Copyright © 2024 optionaldev. All rights reserved.
// 

import UIKit

final class BoardView: UIView {
  
  var flipped: Bool = false
  
  weak var delegate: QuizDelegate?
  
  private(set) var eightRanks: [RankView] = []
  
  func configure(withFen fen: String) {
    let (rows, _) = FenParser.parse(fen: fen)
    
    for (index, rankContent) in rows.enumerated() {
      eightRanks[index].configure(withRankContent: rankContent)
    }
  }
  
  func flip() {
    flipped.toggle()
    
    if flipped {
      transform = CGAffineTransform(rotationAngle: .pi)
    } else {
      transform = CGAffineTransform.identity
    }
    
    for rank in eightRanks {
      for square in rank.eightSquares {
        square.handleNewOrientation(flipped)
      }
    }
  }
  
  func highlight(position: Position) {
    eightRanks[position.column].highlight(item: position.row)
  }
  
  func square(at position: Position) -> SquareView {
    return eightRanks[position.row].eightSquares[position.column]
  }
  
  func unhilight(position: Position) {
    eightRanks[position.column].unhilight(item: position.row)
  }
  
  // MARK: Init
  
  init() {
    super.init(frame: .zero)
    
    for (index, rank) in Rank.allCases.enumerated() {
      let rankView = RankView(rank: rank)
      
      addSubview(rankView)
      
      NSLayoutConstraint.activate([
        rankView.bottomAnchor.constraint(equalTo: bottomAnchor,
                                         constant: -Constants.squareSize * CGFloat(index)),
        rankView.leftAnchor.constraint(equalTo: leftAnchor)
      ])
      
      eightRanks.append(rankView)
    }
    
    translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      widthAnchor.constraint(equalToConstant: Screen.width),
      heightAnchor.constraint(equalToConstant: Screen.width)
    ])
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
