//
// The ChessMind project.
// Created by optionaldev on 25/10/2024.
// Copyright © 2024 optionaldev. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
  
  // MARK: Overrides
  
  override func viewDidLoad() {
    super.viewDidLoad()
    let boardView = BoardView()
    
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
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    let (squareStates, boardSettings) = FenParser.parse(fen: "3r4/q5b1/1p6/2PPB2p/n1BKP1Pr/2NBN3/8/3r4 w - - 0 1")
    
    boardView.configure(withSquareStates: squareStates)
    self.boardSettings = boardSettings
  }
  
  // MARK: - Private
  
  private var boardSettings = BoardSettings()
  private var data: [String: Quiz] = [:]
  private var highlightedPosition: Position?
  
  private weak var boardView: BoardView!
  
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
        break
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
    
    let theoreticalDestinationsMatrix = generateTheoreticalDestinations(forPosition: position)
    
    let possibleDestinationsMatrix = generatePossibleDestinations(fromTheoretical: theoreticalDestinationsMatrix, forPosition: position)
    
    for destinationsArray in possibleDestinationsMatrix {
      for destination in destinationsArray {
        boardView.square(at: destination).highlight(type: .canMove)
      }
    }
  }
  
  private func generatePossibleDestinations(fromTheoretical theoreticalDestinationsMatrix: [[Position]], forPosition position: Position) -> [[Position]] {
    guard case .occupied(let piece, let side) = boardView.square(at: position) .squareState else {
      return []
    }
    
    var result: [[Position]] = []
    var currentPositions: [Position] = []
    
    for destinationsArray in theoreticalDestinationsMatrix {
      for destination in destinationsArray {
        switch boardView.square(at: destination).squareState {
        case .empty:
          /// If the square is empty, we can move there.
          currentPositions.append(destination)
        case .occupied(let targetPiece, let targetSide):
          /// If the square is not empty, we need to check if it's on our side.
          if side != targetSide {
            currentPositions.append(destination)
          }
          
          result.append(currentPositions)
          currentPositions = []
          
        }
        if currentPositions.isEmpty {
          /// We can't break the for loop from inside the switch,
          /// so we do it here.
          break
        }
      }
    }
    
    if currentPositions.isNonEmpty {
      result.append(currentPositions)
    }
    
    return result
  }
  
  /// The idea behind returning Nested array of Moves is that,
  /// each subarray is a list of all theoretically possible
  /// moves in a particular direction. For example a rook
  /// could have 7 possible moves to the right. If we
  /// encounter a piece on the 5th possible move, we
  /// know that we can discard the rest of the subarray. Then
  /// we move on to the next subarray.
  private func generateTheoreticalDestinations(forPosition position: Position) -> [[Position]] {
    let squareView = boardView.square(at: position)
    var result: [[Position]] = []
    var currentMoves: [Position] = []
    
    let pinnedDirections = pinnedDirections(forPosition: position)
    
    guard case .occupied(let piece, let side) = squareView.squareState else {
      return []
    }
    
    switch piece {
    case .bishop:
      let directions = computeDirections([.bottomLeft, .bottomRight, .topLeft, .topRight], withPinnedDirections: pinnedDirections)
      result = generateTheoreticalDestinations(forDirections: directions,
                                               position: position)
    case .king:
      // TODO: Add castling moves
      /// King can never be pinned.
      for direction in Direction.allCases {
        if let newPosition = position.next(inDirection: direction) {
          result.append([newPosition])
        }
      }
    case .knight:
      /// If knight is pinned, knight can never capture its pinner.
      if pinnedDirections.isEmpty {
        for direction in KnightDirection.allCases {
          if let newPosition = position.next(inDirection: direction) {
            result.append([newPosition])
          }
        }
      }
    case .pawn:
      let advanceDirection: Direction?
      let captureDirections: [Direction]
      switch side {
      case .black:
        advanceDirection = computeDirections([.down], withPinnedDirections: pinnedDirections).first
        captureDirections = computeDirections([.bottomLeft, .bottomRight], withPinnedDirections: pinnedDirections)
      case .white:
        advanceDirection = computeDirections([.up], withPinnedDirections: pinnedDirections).first
        captureDirections = computeDirections([.topLeft, .topRight], withPinnedDirections: pinnedDirections)
      }
      let canGoTwoSquares = (side == .black && position.rank == .seventh) ||
      (side == .white && position.rank == .second)
      
      if let advanceDirection = advanceDirection {
        if let newPosition = position.next(inDirection: advanceDirection) {
          currentMoves.append(newPosition)
          if canGoTwoSquares,
             let twoSquaresAdvancePosition = newPosition.next(inDirection: advanceDirection)
          {
            currentMoves.append(twoSquaresAdvancePosition)
          }
        }
      }
      result.append(currentMoves)
      
      for direction in captureDirections {
        if let newPosition = position.next(inDirection: direction) {
          switch boardView.square(at: newPosition).squareState {
          case .empty:
            break
          case .occupied(_, let targetSide):
            if targetSide != side {
              result.append([newPosition])
            }
          }
        }
      }
      
    case .queen:
      let directions = computeDirections(Direction.allCases, withPinnedDirections: pinnedDirections)
      result = generateTheoreticalDestinations(forDirections: directions,
                                               position: position)
    case .rook:
      let directions = computeDirections([.down, .left, .right, .up], withPinnedDirections: pinnedDirections)
      result = generateTheoreticalDestinations(forDirections: directions,
                                               position: position)
    }
    
    return result
  }
  
  private func generateTheoreticalDestinations(forDirections directions: [Direction], position: Position) -> [[Position]] {
    var result: [[Position]] = []
    var currentDestinations: [Position] = []
    
    for direction in directions {
      var referencePosition = position
      while let newPosition = referencePosition.next(inDirection: direction) {
        currentDestinations.append(newPosition)
        referencePosition = newPosition
      }
      if currentDestinations.isNonEmpty {
        result.append(currentDestinations)
      }
      
      currentDestinations = []
    }
    
    return result
  }
  
  @objc private func flipButtonTapped() {
    boardView.flip()
    print("currentFen = \(FenParser.fen(fromSquares: allSquares.map { $0.squareState }, settings: boardSettings))")
  }
  /// The aim of this method is to find directions for which a position is pinned
  /// If for example, the king is on e1 and the position we're trying to
  /// calculate for is e2, then we know that e2 can be pinned up / down,
  /// but not left / right. This means that a pawn will be able to advance,
  /// but not capture. A queen will be able to advance anywhere on the
  /// file, including capturing the pinner.
  private func pinnedDirections(forPosition position: Position) -> [Direction] {
    
    let result: [Direction] = []
    let squareView = boardView.square(at: position)
    
    guard case .occupied(let piece, let side) = squareView.squareState else {
      return []
    }
    
    /// There's no point in calculating pinnings for king,
    /// whether it's white or black king.
    guard piece != .king else {
      return []
    }
    
    var kingDirection: Direction?
    
    for direction in Direction.allCases {
      if let foundKingDirection = findDirectionOfKing(forPosition: position, direction: direction) {
        kingDirection = foundKingDirection
      }
    }
    
    guard let kingDirection = kingDirection else {
      return []
    }
    
    let possiblePinnedDirections = [kingDirection, kingDirection.opposite]
    
    for direction in possiblePinnedDirections {
      let result = findPossiblePins(forPosition: position, direction: direction, possiblePinnedDirections: possiblePinnedDirections)
      
      if result.isNonEmpty {
        return result
      }
    }
    
    return []
  }
  
  private func computeDirections(_ directions: [Direction], withPinnedDirections pinnedDirections: [Direction]) -> [Direction] {
    guard pinnedDirections.isNonEmpty else {
      return directions
    }
    
    return directions.filter { pinnedDirections.contains($0) }
  }
  
  private func findDirectionOfKing(forPosition position: Position, direction: Direction) -> Direction? {
    guard case .occupied(let piece, let side) = boardView.square(at: position).squareState else {
      return nil
    }
    var referencePosition = position
    
    while let newPosition = referencePosition.next(inDirection: direction) {
      switch boardView.square(at: newPosition).squareState {
      case .empty:
        break
      case .occupied(let referencePiece, let referenceSide):
        if referencePiece == .king && side == referenceSide {
          return direction
        } else {
          /// We break because we found another piece and we're looking
          /// for the king. If the king is futher than the piece we found,
          /// there's no pin happening.
          return nil
        }
      }
      referencePosition = newPosition
    }
    
    return nil
  }
  
  private func findPossiblePins(forPosition position: Position, direction: Direction, possiblePinnedDirections: [Direction]) -> [Direction] {
    var referencePosition = position
    while let newPosition = referencePosition.next(inDirection: direction) {
      switch boardView.square(at: newPosition).squareState {
      case .empty:
        break
      case .occupied(let referencePiece, let referenceSide):
        if referenceSide != boardSettings.turn {
          if direction.isDiagonal && (referencePiece == .queen || referencePiece == .bishop) {
            /// Only bishops and queens can pin on diagonals.
            return possiblePinnedDirections
            
          } else if direction.isDiagonal == false && (referencePiece == .queen || referencePiece == .rook) {
            /// Only queens and rooks can pin on ranks / files.
            return possiblePinnedDirections
          } else {
            return []
          }
        } else {
          return []
        }
      }
      
      referencePosition = newPosition
    }
    
    return []
  }
}
