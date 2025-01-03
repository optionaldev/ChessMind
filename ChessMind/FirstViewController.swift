//
// The ChessMind project.
// Created by optionaldev on 21/12/2024.
// Copyright © 2024 optionaldev. All rights reserved.
// 

import UIKit

extension Constants {
  
  static var openingHeight: CGFloat {
    return openingLabelFontSize + 2 * openingLabelPadding
  }
  
  static var lineHeight: CGFloat {
    return lineLabelFontSize + 2 * lineLabelPadding
  }
}

/// This is the entry point of the app.
/// This is where we show a loading spinner and then
/// allow the user to select an opening to practice.
final class FirstViewController: UIViewController, OpeningDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  
  // MARK: Overrides
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let flowLayout = UICollectionViewFlowLayout()
    flowLayout.itemSize = CGSize(width: Screen.width, height: Constants.openingHeight)
    flowLayout.minimumLineSpacing = 5
    
    let openingSelectionCollectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
    openingSelectionCollectionView.dataSource = self
    openingSelectionCollectionView.delegate = self
    openingSelectionCollectionView.register(cellClass: OpeningCell.self)
    openingSelectionCollectionView.translatesAutoresizingMaskIntoConstraints = false
    
    view.addSubview(openingSelectionCollectionView)
    
    NSLayoutConstraint.activate([
      openingSelectionCollectionView.topAnchor.constraint(equalTo: view.topAnchor),
      openingSelectionCollectionView.leftAnchor.constraint(equalTo: view.leftAnchor),
      openingSelectionCollectionView.rightAnchor.constraint(equalTo: view.rightAnchor),
      openingSelectionCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
    ])
    
    self.openingSelectionCollectionView = openingSelectionCollectionView
    
    self.openings = QuizHelper.getOpenings()
  }
  
  // MARK: OpeningDelegate conformance
  
  func didSelect(opening: Opening, lineIndex: Int) {
    openBoard(fen: opening.lines[lineIndex].startingPosition,
              quizFile: opening.temporaryFileName)
  }
  
  // MARK: UICollectionViewDataSource conformance
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return openings.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeu(cellClass: OpeningCell.self, indexPath: indexPath)
    
    cell.configure(opening: openings[indexPath.item],
                   isExpanded: expandedIndexPaths.contains(indexPath))
    cell.delegate = self
    
    return cell
  }
  
  // MARK: UICollectionViewDelegateFlowLayout conformance
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    guard let opening = openings.element(at: indexPath.item) else {
      return
    }
    
    switch opening.lines.count {
      case 0:
        print("Every opening should have at least 1 line.")
      case 1:
        if let startingPosition = opening.lines.first?.startingPosition,
           startingPosition.isNonEmpty
        {
          openBoard(fen: startingPosition, quizFile: opening.temporaryFileName)
        } else {
          print("startingPosition not available for opening \(opening)")
        }
      default:
        expandedIndexPaths.insert(indexPath)
        
        openingSelectionCollectionView.performBatchUpdates(nil, completion: nil)
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let opening = openings[indexPath.item]
    
    if expandedIndexPaths.contains(indexPath) {
      return CGSize(width: Screen.width,
                    height: Constants.openingHeight + opening.lines.count * Constants.lineHeight + (opening.lines.count - 1) * Constants.lineCollectionSpacing)
    }
    return CGSize(width: Screen.width, height: Constants.openingHeight)
  }
  
  // MARK: - Private
  
  private var openings: [Opening] = []
  private var expandedIndexPaths: Set<IndexPath> = []
  
  private weak var openingSelectionCollectionView: UICollectionView!
  
  private func openBoard(fen: String, quizFile: String) {
    let quizes = QuizHelper.getQuizes(forFile: quizFile)
    guard quizes.isNonEmpty else {
      print("Failed to get quizes for quizFile = \(quizFile)")
      return
    }
    
    let boardViewController = BoardViewController(fen: fen, quizes: quizes)
    navigationController?.pushViewController(boardViewController, animated: true)
  }
}
