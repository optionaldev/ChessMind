//
// The ChessMind project.
// Created by optionaldev on 25/10/2024.
// Copyright © 2024 optionaldev. All rights reserved.
//

import UIKit

extension Constants {
  
  static let labelFontSize: CGFloat = 16
  static let labelHorizontalSpacing: CGFloat = 10
  static let labelVerticalSpacing: CGFloat = 20
  
  /// Not entirely sure how to calculate this offset, as it's not
  /// just the navigation bar. For now, it really is a magic number.
  static let verticalOffset: CGFloat = 63
}

final class BoardViewController: UIViewController {
  
  // MARK: Init
  
  init(fen: String, quizes: [String: Quiz]) {
    self.quizes = quizes
    
    switch FenParser.parse(fen: fen).boardSettings.turn {
      case .black:
        self.perspective = .white
      case .white:
        self.perspective = .black
    }
    self.startingFen = fen
    self.fenBeforeAttempt = fen
    
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: Overrides
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let boardView = BoardView()
    
    let flipImage = UIImage(named: "flip")
    let flipButton = UIBarButtonItem(image: flipImage, style: .done, target: self, action: #selector(flipButtonTapped))
      
    let fenLabel = CustomLabel(fontSize: Constants.labelFontSize)
    fenLabel.numberOfLines = 0
    
    let fenCopyButton = UIButton()
    fenCopyButton.addTarget(self, action: #selector(fenCopyPressed), for: .touchUpInside)
    fenCopyButton.setImage(UIImage(systemName: "doc.on.doc.fill"), for: .normal)
    fenCopyButton.translatesAutoresizingMaskIntoConstraints = false
    
    let explanationLabel = CustomLabel(fontSize: Constants.labelFontSize)
    explanationLabel.numberOfLines = 0
    
    let correctMoveLabel = CustomLabel(fontSize: Constants.labelFontSize)
    
    navigationItem.rightBarButtonItem = flipButton
    view.addSubview(boardView)
    view.addSubview(correctMoveLabel)
    view.addSubview(explanationLabel)
    view.addSubview(fenLabel)
    view.addSubview(fenCopyButton)
    view.backgroundColor = .white
    
    NSLayoutConstraint.activate([
      boardView.leftAnchor.constraint(equalTo: view.leftAnchor),
      boardView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      
      fenLabel.topAnchor.constraint(equalTo: boardView.bottomAnchor, constant: Constants.labelVerticalSpacing),
      fenLabel.leftAnchor.constraint(equalTo: boardView.leftAnchor, constant: Constants.labelHorizontalSpacing),
      fenLabel.widthAnchor.constraint(equalToConstant: Screen.width - 80),
      
      fenCopyButton.centerYAnchor.constraint(equalTo: fenLabel.centerYAnchor),
      fenCopyButton.leftAnchor.constraint(equalTo: fenLabel.rightAnchor, constant: 14),
      
      correctMoveLabel.topAnchor.constraint(equalTo: fenLabel.bottomAnchor, constant: Constants.labelVerticalSpacing),
      correctMoveLabel.leftAnchor.constraint(equalTo: fenLabel.leftAnchor),
      
      explanationLabel.topAnchor.constraint(equalTo: correctMoveLabel.bottomAnchor, constant: 8),
      explanationLabel.leftAnchor.constraint(equalTo: correctMoveLabel.leftAnchor),
      explanationLabel.widthAnchor.constraint(equalToConstant: Screen.width - 2 * Constants.labelHorizontalSpacing)
    ])
    
    self.boardView = boardView
    
    allSquares.forEach {
      let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapSquare))
      $0.addGestureRecognizer(tapGestureRecognizer)
    }
    
    self.correctMoveLabel = correctMoveLabel
    self.explanationLabel = explanationLabel
    self.fenLabel = fenLabel
    
    /// This helps prevent the delay for playing AV stuff.
    _ = SoundSingleton.shared
    
    /// Testing checks
    //    let (squareStates, boardSettings) = FenParser.parse(fen: "3qkr2/npp3pp/r2bN3/2n3b1/2N5/3B4/8/R1BQR1K1 w Q - 0 1")
    
    /// Testing castling
    //    let (squareStates, boardSettings) = FenParser.parse(fen: "r3k2r/pppppppp/8/8/8/8/PPPPPPPP/R3K2R w KQkq - 0 1")
    
    /// Testing pins
//        let (squareStates, boardSettings) = FenParser.parse(fen: "2kr4/q5b1/1p6/2PPB2p/n1BKP1Pr/2NBN3/8/3r4 b - - 0 1")
    
    /// Testing protected squares
//    let (squareStates, boardSettings) = FenParser.parse(fen: "rnbqkbnr/ppp3pp/8/8/6R1/7B/PPP3PP/RNBQK1N1 w HQkq - 0 1")
    
    setFen(startingFen)
    
    /// In case next to move is white after initial load, it means
    /// we're playing from the black perspective.
    if boardSettings.turn == .white {
      boardView.flip()
    }
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
      self?.handleQuizPart()
    }
  }
  
  // MARK: - Private
  
  // MARK: Constants
  
  /// The side for which the user is playing. Useful for if the next
  /// move is the user and it should wait or it should play a move for
  /// the opponent.
  private let perspective: Side
  
  /// This is the entire database that we need for the quizes
  private let quizes: [String: Quiz]
  
  /// We use this once to set up the board at the start. We store it
  /// because the view isn't ready when initializing. We could
  /// avoid having this if we declared the view separately.
  private let startingFen: String
  
  // MARK: Variables
  
  /// Setting that keep track of parameters relevant for FEN notation:
  /// castling rights, en passant, who's turn it is, number of black moves,
  /// number of
  private var boardSettings = BoardSettings()
  
  /// While we're quizing, it's useful to know why we do a certain
  /// move, to be abl to better remember it.
  private var expectedMoveExplanation: String?
  
  /// After the opponent does a move, we look at quizes to see what
  /// the expected next move should be. Only 1 move is valid.
  private var expectedMoveNotation: String?
  
  /// We record current fen because if a move happens and it was the
  /// incorrect one, we need to know the FEN to which to revert.
  /// Another approach would be to reverse the moves, which we
  /// might implement in the future.
  private var fenBeforeAttempt: String
  
  /// We keep the highlited position because a move only happens
  /// after 2 actions at least and many things can happen in two
  /// moves. The user can select another position, he can reselect
  /// the same position, etc.
  private var highlightedPosition: Position?
  
  /// We keep a list of legal destinations for currently selected
  /// piece because finding all legal destinations can take a while
  /// and we don't want to redo calculations every time we need the
  /// legal destinations.
  private var legalDestination: [Position] = []
  
  // MARK: Computed
  
  private var allSquares: [SquareView] {
    return boardView.eightRanks.flatMap { $0.eightSquares }
  }
  
  private var allSquareStates: [[SquareState]] {
    return boardView.eightRanks.map { $0.eightSquares.map { $0.squareState }}
  }
  
  private var currentFen: String {
    return FenParser.fen(forBoard: allSquareStates.reversed(), settings: boardSettings)
  }
  
  // MARK: Weak
  
  private weak var boardView: BoardView!
  private weak var fenLabel: CustomLabel!
  private weak var explanationLabel: CustomLabel!
  private weak var correctMoveLabel: CustomLabel!
  
  private func animate(move: Move, imageName: String) {
    let fromSquare = boardView.square(at: move.from)
    let toSquare = boardView.square(at: move.to)
    
    let temporaryPieceView = UIImageView(image: UIImage(named: imageName), highlightedImage: nil)
    temporaryPieceView.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
    temporaryPieceView.frame = fromSquare.position.frame(isBoardFlipped: boardView.flipped, verticalOffset: Constants.verticalOffset)
    
    view.addSubview(temporaryPieceView)
    
    UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseInOut, animations: { [weak self] in
      guard let self = self else {
        return
      }
      temporaryPieceView.frame = toSquare.position.frame(isBoardFlipped: self.boardView.flipped, verticalOffset: Constants.verticalOffset)
    }, completion: { [weak self] _ in
      
      toSquare.show()
      temporaryPieceView.removeFromSuperview()
      
      self?.handleAnimationCompletion(move: move)
    })
  }
  
  @objc private func didTapSquare(_ gestureRecognizer: UITapGestureRecognizer) {
    guard let squareView = gestureRecognizer.view as? SquareView else {
      fatalError("Shouldn't be possible to find something else other than a \(SquareView.self)")
    }
    let position = squareView.position
    
    guard perspective == boardSettings.turn else {
      /// We don't allow user to select while it's the "computer"'s
      /// turn to play.
      return
    }
    
    if let highlightedPosition = highlightedPosition {
      allSquares.forEach { $0.unhighlight(type: .canMove) }
      /// If we already have a highlighted positions, there's 4 scenarios:
      if highlightedPosition == position {
        /// 1) Tapping the same square, resulting in deselection.
        squareView.unhighlight(type: .isSelected)
        self.highlightedPosition = nil
      } else {
        let currentlyHighlightedSquare = boardView.square(at: highlightedPosition)
        guard currentlyHighlightedSquare.position == highlightedPosition else
        {
          fatalError("These positions should be the same (\(highlightedPosition) and \(currentlyHighlightedSquare.position). What is happening?")
        }
        
        guard case .occupied = currentlyHighlightedSquare.squareState else {
          fatalError("Trying to move an empty square????")
        }
        
        currentlyHighlightedSquare.unhighlight(type: .isSelected)
        
        switch squareView.squareState {
          case .empty:
            guard legalDestination.contains(position) else {
              self.highlightedPosition = nil
              return
            }
            boardView.isUserInteractionEnabled = false
            /// 2) Tapped on an empty square. Should move selected piece here.
            allSquares.forEach { $0.unhighlight(type: .previousMove(move: .from)) }
            
            let nextMove = Move(from: highlightedPosition, to: position)
            
            handleCastlingIfNeeded(move: nextMove)
            
            handleEnPassant(move: nextMove)
            
            handle(move: nextMove, updateSide: true, isCapture: false)
            
            boardView.square(at: nextMove.from).highlight(type: .previousMove(move: .from))
            boardView.square(at: nextMove.to).highlight(type: .previousMove(move: .to))
            
          case .occupied(_, let side):
            if side == boardSettings.turn {
              /// 3) Tapped on a piece from the same side.
              handleNewHighlightedSquare(position: position)
            } else {
              guard legalDestination.contains(position) else {
                return
              }
              /// 4) Tapped on an enemy piece. Should capture.
              
              boardView.isUserInteractionEnabled = false
              
              allSquares.forEach { $0.unhighlight(type: .previousMove(move: .from)) }
              
              let nextMove = Move(from: highlightedPosition, to: position)
              
              handle(move: nextMove, updateSide: true, isCapture: true)
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
  
  @objc private func fenCopyPressed() {
    UIPasteboard.general.string = fenBeforeAttempt
  }
  
  @objc private func flipButtonTapped() {
    boardView.flip()
  }
  
  private func handle(move: Move, updateSide: Bool, isCapture: Bool) {
    let fromSquare = boardView.square(at: move.from)
    let toSquare = boardView.square(at: move.to)
    
    let oldFromSquareState = fromSquare.squareState
    let oldToSquareState = toSquare.squareState
    
    guard let imageName = fromSquare.squareState.imageName else {
      fatalError("Moving a piece with no image?")
    }
    
    /// Configuring toSquare first is a MUST.
    toSquare.configure(squareState: fromSquare.squareState, shouldHideUntilAnimationFinishes: true)
    fromSquare.configure(squareState: .empty, shouldHideUntilAnimationFinishes: false)
    
    if updateSide {
      boardSettings.turn.toggle()
    }
    
    allSquares.forEach { $0.unhighlight(type: .kingIsInCheck) }
    
    if BoardHelper.isKingInCheck(onBoard: allSquareStates, boardSettings: boardSettings) {
      SoundSingleton.shared.play(.check)
      let kingPosition = BoardHelper.findKing(onBoard: allSquareStates, boardSettings: boardSettings)
      boardView.square(at: kingPosition).highlight(type: .kingIsInCheck)
      boardSettings.kingIsInCheck = true
    } else if isCapture {
      SoundSingleton.shared.play(.capture)
    } else {
      SoundSingleton.shared.play(.move)
    }
    
    /// If the rooks move, that side loses castling right for the
    /// side of the rook.
    if move.from == Position(rank: .first, file: .h) {
      boardSettings.whiteCastling.remove(.kingSide)
    } else if move.from == Position(rank: .first, file: .a) {
      boardSettings.whiteCastling.remove(.queenSide)
    } else if move.from == Position(rank: .eighth, file: .h) {
      boardSettings.blackCastling.remove(.kingSide)
    } else if move.from == Position(rank: .eighth, file: .a) {
      boardSettings.blackCastling.remove(.queenSide)
    }
    
    if case .occupied(let piece, let side) = boardView.square(at: move.from).squareState {
      if piece == .king {
        switch side {
          case .black:
            boardSettings.blackCastling.removeAll()
          case .white:
            boardSettings.whiteCastling.removeAll()
        }
      }
    }
    
    animate(move: move, imageName: imageName)
    
    boardView.square(at: move.from).highlight(type: .previousMove(move: .from))
    boardView.square(at: move.to).highlight(type: .previousMove(move: .to))
    
    if updateSide {
      if perspective != boardSettings.turn {
        let notation = BoardHelper.notation(forMove: move,
                                            fromSquare: oldFromSquareState,
                                            toSquare: oldToSquareState,
                                            onBoard: allSquareStates,
                                            boardSettings: boardSettings)
        if expectedMoveNotation == notation {
          handleQuizPart()
        } else {
          DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.setFen(self.fenBeforeAttempt)
            
            if let move = self.expectedMoveNotation,
               let explanation = self.expectedMoveExplanation
            {
              self.correctMoveLabel.attributedText = "Correct: ".attributed(color: .red) + move
              self.explanationLabel.attributedText = "Explanation: ".attributed(color: .gray) + explanation
            }
          }
        }
      } else {
        fenBeforeAttempt = currentFen
        fenLabel.attributedText = "FEN: ".attributed(color: .gray) + fenBeforeAttempt
        handleQuizPart()
      }
    }
  }
  
  private func handleAnimationCompletion(move: Move) {
    if boardSettings.enPassant == move.to,
       case .occupied(let piece, _) = boardView.square(at: move.to).squareState,
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
        boardView.square(at: position).configure(squareState: .empty, shouldHideUntilAnimationFinishes: false)
        boardSettings.enPassant = nil
      }
    }
    
    highlightedPosition = nil
    
    boardView.isUserInteractionEnabled = true
  }
  
  private func handleCastlingIfNeeded(move: Move)   {
    /// We make sure that the king is trying to move two squares away.
    guard case .occupied(let piece, _) = boardView.square(at: move.from).squareState,
          piece == .king,
          abs(move.from.file.rawValue - move.to.file.rawValue) == 2 else
    {
      return
    }
    let fromPosition: Position
    let toPosition: Position
    if move.to.file == .c {
      /// If the king (either white or black) is trying to move to the
      /// c file, it's long castling.
      fromPosition = Position(rank: move.from.rank, file: .a)
      toPosition = Position(rank: move.from.rank, file: .d)
    } else {
      /// If the king (either white or black) is not trying to move to
      /// the c file, but is still moving two squares away, it's short
      /// castling.
      fromPosition = Position(rank: move.from.rank, file: .h)
      toPosition = Position(rank: move.from.rank, file: .f)
    }
    
    let fromSquare = boardView.square(at: fromPosition)
    
    boardView.square(at: toPosition).configure(squareState: fromSquare.squareState, shouldHideUntilAnimationFinishes: true)
    boardView.square(at: fromPosition).configure(squareState: .empty, shouldHideUntilAnimationFinishes: false)
    
    animate(move: Move(from: fromPosition, to: toPosition),
            imageName: Piece.rook.imageName(forSide: move.from.rank == .first ? .white : .black))
    
    if move.from.rank == .first {
      boardSettings.whiteCastling = []
    } else {
      boardSettings.blackCastling = []
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
  
  private func handleNewHighlightedSquare(position: Position) {
    allSquares.forEach { $0.unhighlight(type: .canMove) }
    
    let squareView = boardView.square(at: position)
    
    guard position == squareView.position else {
      fatalError("These should be equal.")
    }
    
    /// Need to check for valid highlight option
    squareView.highlight(type: .isSelected)
    highlightedPosition = position
    
    let legalDestinations = BoardHelper.calculateLegalDestinations(forPieceAtPosition: position,
                                                                   onBoard: allSquareStates,
                                                                   boardSettings: boardSettings)
    
    for destination in legalDestinations {
      boardView.square(at: destination).highlight(type: .canMove)
    }
    self.legalDestination = legalDestinations
  }
  
  private func handleQuizPart() {
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
      self.handleQuiz()
    }
  }
  
  private func handleQuiz() {
    let currentFen = currentFen
    
    guard let quiz = quizes[currentFen] else {
      print("The end of the line? currentFen = \(currentFen)")
      return
    }
    
    switch quiz {
    case .myMove(let moveNotation, let explanation):
      if boardSettings.turn == perspective {
        expectedMoveNotation = moveNotation
        expectedMoveExplanation = explanation
      } else {
        print("We should have a move for us, not the opponent.")
      }
    case .opponentMoves(let possibleOpponentMoveNotations):
      
      if let move = expectedMoveNotation,
         let explanation = expectedMoveExplanation
      {
        correctMoveLabel.attributedText = "Correct: ".attributed(color: .darkSquareColor) + move
        explanationLabel.attributedText = "Explanation: ".attributed(color: .gray) + explanation
      }
      
      if boardSettings.turn != perspective {
        guard let moveNotation = possibleOpponentMoveNotations.randomElement() else {
          print("Opponent has no moves.")
          return
        }
        
        let movesArray = BoardHelper.moves(forNotation: moveNotation, onBoard: allSquareStates, boardSettings: boardSettings)
        
        if let firstMove = movesArray.first {
          handle(move: firstMove.move, updateSide: true, isCapture: firstMove.isCapture)
        }
        
        if movesArray.count > 1,
           let secondMove = movesArray.last
        {
          handle(move: secondMove.move, updateSide: false, isCapture: secondMove.isCapture)
        }
      } else {
        print("We should have a move for the opponent, not us.")
      }
    }
  }
  
  private func setFen(_ fen: String) {
    let (squareStates, boardSettings) = FenParser.parse(fen: fen)
    boardView.configure(withSquareStates: squareStates)
    self.boardSettings = boardSettings
  }
}
