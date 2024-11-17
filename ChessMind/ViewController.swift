//
// The ChessMind project.
// Created by optionaldev on 25/10/2024.
// Copyright © 2024 optionaldev. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let boardView = BoardView()
    boardView.configure(withFen: "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1")
    
    let flipButton = UIButton(type: .system)
    flipButton.addTarget(self, action: #selector(flipButtonTapped), for: .touchUpInside)
    flipButton.setImage(UIImage(named: "flip"), for: .normal)
    flipButton.translatesAutoresizingMaskIntoConstraints = false
    
    view.addSubview(boardView)
    view.addSubview(flipButton)
    view.translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint.activate([
      boardView.leftAnchor.constraint(equalTo: view.leftAnchor),
      boardView.topAnchor.constraint(equalTo: view.topAnchor, constant: Constants.boardTopOffset),
      
      flipButton.heightAnchor.constraint(equalToConstant: 50),
      flipButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      flipButton.topAnchor.constraint(equalTo: boardView.bottomAnchor, constant: 50),
      flipButton.widthAnchor.constraint(equalToConstant: 50)
    ])
    
    self.boardView = boardView
    
    allSquares.forEach {
      let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapSquare))
      $0.addGestureRecognizer(tapGestureRecognizer)
    }
  }
  
  // MARK: - Private
  
  private var boardView: BoardView!
  private var data: [String: Quiz] = [:]
  private var highlightedPosition: Position?
  private var side: Side = .white
  
  private var allSquares: [SquareView] {
    return boardView.eightRanks.flatMap { $0.eightSquares }
  }
  
  private func animate(move: Move) {
    let fromSquare = boardView.square(at: move.from)
    let toSquare = boardView.square(at: move.to)
    let destinationSquareState = fromSquare.squareState
    
    guard let imageName = fromSquare.squareState.imageName else {
      fatalError("Moving a piece with no image?")
    }
    
    fromSquare.configure(squareState: .empty)
    
    let temporaryPieceView = UIImageView(image: UIImage(named: imageName), highlightedImage: nil)
    temporaryPieceView.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
    temporaryPieceView.frame = fromSquare.position.frame(isBoardFlipped: boardView.flipped)
    
    view.addSubview(temporaryPieceView)
    
    UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: { [weak self] in
      guard let self = self else {
        return
      }
      temporaryPieceView.frame = toSquare.position.frame(isBoardFlipped: self.boardView.flipped)
    }, completion: { _ in
      toSquare.configure(squareState: destinationSquareState)
      temporaryPieceView.removeFromSuperview()
    })
  }
  
  @objc private func didTapSquare(_ gestureRecognizer: UITapGestureRecognizer) {
    guard let squareView = gestureRecognizer.view as? SquareView else {
      fatalError("Shouldn't be possible to find something else other than a \(SquareView.self)")
    }
    let position = squareView.position
    
    if let highlightedPosition = highlightedPosition {
      if highlightedPosition == position {
        squareView.unhighlight(type: .isSelected)
        allSquares.forEach { $0.unhighlight(type: .canMove) }
        self.highlightedPosition = nil
      } else {
        let currentlyHighlightedSquare = boardView.square(at: highlightedPosition)
        guard currentlyHighlightedSquare.position == highlightedPosition else {
          fatalError("What is happening here?")
        }
        currentlyHighlightedSquare.unhighlight(type: .isSelected)
        
        switch squareView.squareState {
          case .empty:
            allSquares.forEach { $0.unhighlight(type: .previousMove(move: .from)) }

            let nextMove = Move(from: highlightedPosition, to: position)
            animate(move: nextMove)
            
            boardView.square(at: nextMove.from).highlight(type: .previousMove(move: .from))
            boardView.square(at: nextMove.to).highlight(type: .previousMove(move: .to))
            
          case .occupied(let piece, _):
            break
        }

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
    allSquares.forEach { $0.unhighlight(type: .canMove) }
    
    let squareView = boardView.square(at: position)
    
    guard position == squareView.position else {
      fatalError("These should be equal")
    }
    
    /// Need to check for valid highlight option
    squareView.highlight(type: .isSelected)
    highlightedPosition = position
    
    let movesMatrix = generateTheoreticalMoves(forPosition: position)
    
    for movesArray in movesMatrix {
      for move in movesArray {
        boardView.square(at: move.to).highlight(type: .canMove)
      }
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
    let squareView = boardView.square(at: position)
    var result: [[Move]] = []
    var currentMoves: [Move] = []
    
    guard case .occupied(let piece, let side) = squareView.squareState else {
      return []
    }
    
    switch piece {
      case .bishop:
        result = generateTheoreticalMoves(forDirections: [.bottomLeft, .bottomRight, .topLeft, .topRight],
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
  
  @objc private func flipButtonTapped() {
    boardView.flip()
  }
}

