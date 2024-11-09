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
//    boardView.configure(withFen: "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1")
    
    for rank in boardView.eightRanks {
      for file in rank.eightSquares {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapSquare))
        file.addGestureRecognizer(tapGestureRecognizer)
      }
    }
    
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
  private var side: Side = .white
  
  @objc private func didTapSquare(_ gestureRecognizer: UITapGestureRecognizer) {
    guard let squareView = gestureRecognizer.view as? SquareView else {
      fatalError("Shouldn't be possible to find something else other than a \(SquareView.self)")
    }
    
    if let highlightedPosition = highlightedPosition {
      if highlightedPosition == squareView.position {
        squareView.unhilight()
        self.highlightedPosition = nil
      } else {
        boardView.square(at: highlightedPosition).unhilight()
        /// Need to check for valid highlight option
        squareView.highlight()
        self.highlightedPosition = squareView.position
      }
    } else {
      if case .empty = squareView.square {
        return
      }
      squareView.highlight()
      highlightedPosition = squareView.position
      /// TODO: Find legal moves
    }
  }
  
  /// The idea behind returning Nested array of Moves is that,
  /// each subarray is a list of all theoretically possible
  /// moves in a particular direction. For example a rook
  /// could have 7 possible moves to the right. If we
  /// encounter a piece on the 5th possible move, we
  /// know that we can discard the rest of the subarray. Then
  /// we move on to the next subarray.
  private func generateTheoreticalMoves(forPosition position: Position) -> [[Move]] {
    return []
  }
}

