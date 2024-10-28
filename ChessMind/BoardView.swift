//
// The ChessMind project.
// Created by optionaldev on 25/10/2024.
// Copyright © 2024 optionaldev. All rights reserved.
// 

import UIKit

final class BoardView: UIView {
  
  weak var delegate: QuizDelegate?
  
  private(set) var eightRows: [RowView] = []
  
  func configure(withFen fen: String) {
    let (rows, canCastle) = FenParser.parse(fen: fen)
    
    for (index, row) in rows.enumerated() {
      eightRows[index].configure(withRow: row)
    }
  }
  
  func highlight(position: Position) {
    eightRows[position.row].highlight(item: position.column)
  }
  
  func unhilight(position: Position) {
    eightRows[position.row].unhilight(item: position.column)
  }
  
  // MARK: Init
  
  init() {
    super.init(frame: .zero)
    
    for index in 0..<Constants.boardLength {
      let rowView = RowView(index: index)
      
      addSubview(rowView)
      
      NSLayoutConstraint.activate([
        rowView.topAnchor.constraint(equalTo: topAnchor,
                                     constant: Constants.squareSize * CGFloat(index)),
        rowView.leftAnchor.constraint(equalTo: leftAnchor)
      ])
      
      eightRows.append(rowView)
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
