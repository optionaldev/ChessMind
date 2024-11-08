//
// The ChessMind project.
// Created by optionaldev on 25/10/2024.
// Copyright © 2024 optionaldev. All rights reserved.
// 

import UIKit

final class BoardView: UIView {
  
  weak var delegate: QuizDelegate?
  
  private(set) var eightRanks: [RankView] = []
  
  func configure(withFen fen: String) {
    let (rows, _) = FenParser.parse(fen: fen)
    
    for (index, rank) in rows.enumerated() {
      eightRanks[index].configure(withRank: rank)
    }
  }
  
  func highlight(position: Position) {
    eightRanks[position.row].highlight(item: position.column)
  }
  
  func unhilight(position: Position) {
    eightRanks[position.row].unhilight(item: position.column)
  }
  
  // MARK: Init
  
  init() {
    super.init(frame: .zero)
    
    for rank in 0..<Constants.boardLength {
      let rankView = RankView(rank: rank)
      
      addSubview(rankView)
      
      NSLayoutConstraint.activate([
        rankView.topAnchor.constraint(equalTo: topAnchor,
                                     constant: Constants.squareSize * CGFloat(rank)),
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
