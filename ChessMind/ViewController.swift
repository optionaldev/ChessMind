//
// The ChessMind project.
// Created by optionaldev on 25/10/2024.
// Copyright © 2024 optionaldev. All rights reserved.
//

import UIKit

protocol QuizDelegate: AnyObject {
  
  func didTap(position: Position)
}

class ViewController: UIViewController, QuizDelegate {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let boardView = BoardView()
    boardView.delegate = self
    
    view.addSubview(boardView)
    view.translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint.activate([
      boardView.topAnchor.constraint(equalTo: view.topAnchor, constant: 50),
      boardView.leftAnchor.constraint(equalTo: view.leftAnchor)
    ])
    
    self.boardView = boardView
  }
  
  // MARK: QuizDelegate conformance
  
  func didTap(position: Position) {
    if let highlightedPosition = highlightedPosition {
      if position == highlightedPosition {
        boardView.unhilight(position: position)
      }
    }
  }
  
  
  
  // MARK: - Private
  
  private var boardView: BoardView!
  private var data: [String: Quiz] = [:]
  private var highlightedPosition: Position?
}

