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
    boardView.configure(withFen: "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1")
    
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
    let position = squareView.position
    
    if let highlightedPosition = highlightedPosition {
      if highlightedPosition == position {
        squareView.unhilight()
        self.highlightedPosition = nil
      } else {
        let currentlyHighlightedSquare = boardView.square(at: highlightedPosition)
        guard currentlyHighlightedSquare.position == highlightedPosition else {
          fatalError("What is happening here?")
        }
        currentlyHighlightedSquare.unhilight()

        handleNewHighlightedSquare(position: position)
      }
    } else {
      switch squareView.squareState {
        case .empty:
          return
        case .occupied:
          handleNewHighlightedSquare(position: position)
      }
    }
  }
  
  private func handleNewHighlightedSquare(position: Position) {
    let squareView = boardView.square(at: position)
    
    guard position == squareView.position else {
      fatalError("These should be equal")
    }
    
    /// Need to check for valid highlight option
    squareView.highlight()
    highlightedPosition = position
    
    let moves = generateTheoreticalMoves(forPosition: position)
    
    print(moves)
  }
  
  /// The idea behind returning Nested array of Moves is that,
  /// each subarray is a list of all theoretically possible
  /// moves in a particular direction. For example a rook
  /// could have 7 possible moves to the right. If we
  /// encounter a piece on the 5th possible move, we
  /// know that we can discard the rest of the subarray. Then
  /// we move on to the next subarray.
  private func generateTheoreticalMoves(forPosition position: Position) -> [[Move]] {
    let squareView = boardView.square(at: position)
    var result: [[Move]] = []
    var currentMoves: [Move] = []
    
    guard case .occupied(let piece, let side) = squareView.squareState else {
      return []
    }
    
    switch piece {
      case .bishop:
        generateTheoreticalMoves(forDirections: [.bottomLeft, .bottomRight, .topLeft, .topRight],
                                 position: position)
      case .king:
        for direction in Direction.allCases {
          if let newPosition = position.next(inDirection: direction) {
            result.append([Move(from: position, to: newPosition)])
          }
        }
        // TODO: Add castling moves
      case .knight:
        for direction in KnightDirection.allCases {
          if let newPosition = position.next(inDirection: direction) {
            result.append([Move(from: position, to: newPosition)])
          }
        }
      case .pawn:
        let advanceDirection: Direction
        let captureDirections: [Direction]
        switch side {
          case .black:
            advanceDirection = .down
            captureDirections = [.bottomLeft, .bottomRight]
          case .white:
            advanceDirection = .up
            captureDirections = [.topLeft, .topRight]
        }
        let canGoTwoSquares = (side == .black && position.rank == .seventh) ||
        (side == .white && position.rank == .second)
        
        if let newPosition = position.next(inDirection: advanceDirection) {
          currentMoves.append(Move(from: position, to: newPosition))
          if canGoTwoSquares,
             let twoSquaresAdvancePosition = newPosition.next(inDirection: advanceDirection)
          {
            currentMoves.append(Move(from: position, to: twoSquaresAdvancePosition))
          }
        }
        result.append(currentMoves)
        
        for direction in captureDirections {
          if let newPosition = position.next(inDirection: direction) {
            result.append([Move(from: position, to: newPosition)])
          }
        }
        
      case .queen:
        result = generateTheoreticalMoves(forDirections: Direction.allCases,
                                          position: position)
      case .rook:
        result = generateTheoreticalMoves(forDirections: [.down, .left, .right, .up],
                                          position: position)
    }
    
    return result
  }
  
  private func generateTheoreticalMoves(forDirections directions: [Direction], position: Position) -> [[Move]] {
    var result: [[Move]] = []
    var currentMoves: [Move] = []
    
    for direction in directions {
      var referencePosition = position
      while let newPosition = referencePosition.next(inDirection: direction) {
        currentMoves.append(Move(from: position, to: newPosition))
        referencePosition = newPosition
      }
      if currentMoves.isNonEmpty {
        result.append(currentMoves)
      }
      
      currentMoves = []
    }
    
    return result
  }
}

