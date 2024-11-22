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
    let (squareStates, boardSettings) = FenParser.parse(fen: "r3k2r/pppppppp/8/8/8/8/PPPPPPPP/R3K2R w KQkq - 0 1")
//    let (squareStates, boardSettings) = FenParser.parse(fen: "2kr4/q5b1/1p6/2PPB2p/n1BKP1Pr/2NBN3/8/3r4 b - - 0 1")
    
    boardView.configure(withSquareStates: squareStates)
    self.boardSettings = boardSettings
  }
  
  // MARK: - Private
  
  private var boardSettings = BoardSettings()
  private var data: [String: Quiz] = [:]
  private var highlightedPosition: Position?
  private var legalDestination: [Position] = []
  
  private weak var boardView: BoardView!
  
  private var allSquares: [SquareView] {
    return boardView.eightRanks.flatMap { $0.eightSquares }
  }
  
  private var allSquareStates: [[SquareState]] {
    return boardView.eightRanks.map { $0.eightSquares.map { $0.squareState }}
  }
  
  private func animate(move: Move, updateSide: Bool) {
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
    }, completion: { [weak self] _ in
      toSquare.configure(squareState: destinationSquareState)
      temporaryPieceView.removeFromSuperview()
      
      self?.handleAnimationCompletion(move: move, updateSide: updateSide)
    })
  }
  
  private func handleAnimationCompletion(move: Move, updateSide: Bool) {
    if boardSettings.enPassant == move.to,
       case .occupied(let piece, _) = boardView.square(at: move.from).squareState,
       piece == .pawn
    {
      // Remove the pawn that passed the capturing pawn.
      let offset: Int
      switch boardSettings.turn {
      case .black:
        offset = -1
      case .white:
        offset = 1
      }
      if let position = Position(row: move.to.row + offset, column: move.to.column) {
        boardView.square(at: position).configure(squareState: .empty)
      }
    }
    
    if updateSide {
      boardSettings.turn.toggle()
    }
    
    if BoardHelper.isKingInCheck(onBoard: allSquareStates, boardSettings: boardSettings) {
      let kingPosition = BoardHelper.findKing(onBoard: allSquareStates, boardSettings: boardSettings)
      boardView.square(at: kingPosition).highlight(type: .kingIsInCheck)
      boardSettings.kingIsInCheck = true
    }
    
    highlightedPosition = nil
    boardView.isUserInteractionEnabled = true
  }
  
  @objc private func didTapSquare(_ gestureRecognizer: UITapGestureRecognizer) {
    guard let squareView = gestureRecognizer.view as? SquareView else {
      fatalError("Shouldn't be possible to find something else other than a \(SquareView.self)")
    }
    let position = squareView.position
    
    if let highlightedPosition = highlightedPosition {
      allSquares.forEach { $0.unhighlight(type: .canMove) }
      /// If we already have a highlighted positions, there's 4 scenarios:
      if highlightedPosition == position {
        print("Case 1, tapped on same square")
        /// 1) Tapping the same square, resulting in deselection.
        squareView.unhighlight(type: .isSelected)
        self.highlightedPosition = nil
      } else {
        let currentlyHighlightedSquare = boardView.square(at: highlightedPosition)
        guard currentlyHighlightedSquare.position == highlightedPosition else {
          fatalError("These positions should be the same (\(highlightedPosition) and \(currentlyHighlightedSquare.position). What is happening?")
        }
        currentlyHighlightedSquare.unhighlight(type: .isSelected)
        
        switch squareView.squareState {
        case .empty:
          guard legalDestination.contains(position) else {
            self.highlightedPosition = nil
            return
          }
          boardView.isUserInteractionEnabled = false
          
          print("Case 2, tapped on empty square. We make a move.")
          /// 2) Tapped on an empty square. Should move selected piece here.
          allSquares.forEach { $0.unhighlight(type: .previousMove(move: .from)) }
          
          let nextMove = Move(from: highlightedPosition, to: position)
          
          handleCastlingIfNeeded(move: nextMove)
          
          boardSettings.enPassant = nil
          handleEnPassant(move: nextMove)
          
          animate(move: nextMove, updateSide: true)
          
          boardView.square(at: nextMove.from).highlight(type: .previousMove(move: .from))
          boardView.square(at: nextMove.to).highlight(type: .previousMove(move: .to))
          
        case .occupied(_, let side):
          if side == boardSettings.turn {
            print("Case 3, piece from same side. We select it.")
            /// 3) Tapped on a piece from the same side.
            handleNewHighlightedSquare(position: position)
          } else {
            guard legalDestination.contains(position) else {
              return
            }
            print("Case 4, capturing enemy piece. We make a move.")
            /// 4) Tapped on an enemy piece. Should capture.
            
            boardView.isUserInteractionEnabled = false
            
            allSquares.forEach { $0.unhighlight(type: .previousMove(move: .from)) }
            
            let nextMove = Move(from: highlightedPosition, to: position)
            
            animate(move: nextMove, updateSide: true)
            
            boardView.square(at: nextMove.from).highlight(type: .previousMove(move: .from))
            boardView.square(at: nextMove.to).highlight(type: .previousMove(move: .to))
          }
        }
      }
    } else {
      switch squareView.squareState {
      case .empty:
        squareView.unhighlight(type: .isSelected)
        allSquares.forEach { $0.unhighlight(type: .canMove) }
      case .occupied(_, let side):
        if side == boardSettings.turn {
          handleNewHighlightedSquare(position: position)
        }
      }
    }
  }
  
  private func handleEnPassant(move: Move) {
    guard case .occupied(let piece, _) = boardView.square(at: move.from).squareState,
          piece == .pawn,
          abs(move.from.rank.rawValue - move.to.rank.rawValue) == 2 else
    {
      return
    }
    boardSettings.enPassant = Position(row: max(move.to.row, move.from.row) - 1,
                                       /// For column, it doesn't matter if it's "from" or "to". They're the same
                                       column: move.from.column)
  }
  
  private func handleCastlingIfNeeded(move: Move) {
    guard case .occupied(let piece, _) = boardView.square(at: move.from).squareState,
          piece == .king,
          abs(move.from.file.rawValue - move.to.file.rawValue) == 2 else
    {
      return
    }
     
    if move.to.file == .c {
      animate(move: Move(from: Position(rank: move.from.rank, file: .a), to: Position(rank: move.from.rank, file: .d)), updateSide: false)
    } else {
      animate(move: Move(from: Position(rank: move.from.rank, file: .h), to: Position(rank: move.from.rank, file: .f)), updateSide: false)
    }
  }
  
  private func handleNewHighlightedSquare(position: Position) {
    allSquares.forEach { $0.unhighlight(type: .canMove) }
    
    let squareView = boardView.square(at: position)
    
    guard position == squareView.position else {
      fatalError("These should be equal.")
    }
    
    /// Need to check for valid highlight option
    squareView.highlight(type: .isSelected)
    highlightedPosition = position
    
    let legalDestinations = BoardHelper.generateLegalDestinations(forPosition: position,
                                                                  onBoard: allSquareStates,
                                                                  boardSettings: boardSettings)
    
    for destination in legalDestinations {
      boardView.square(at: destination).highlight(type: .canMove)
    }
    self.legalDestination = legalDestinations
  }
  
  
  @objc private func flipButtonTapped() {
    boardView.flip()
    print("currentFen = \(FenParser.fen(fromSquares: allSquares.map { $0.squareState }, settings: boardSettings))")
  }
  
}
