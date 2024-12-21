//
// The ChessMind project.
// Created by optionaldev on 21/12/2024.
// Copyright © 2024 optionaldev. All rights reserved.
// 

import UIKit

extension Constants {
  
  static let cellIdentifier = "openingCell"
}

/// This is the entry point of the app.
/// This is where we show a loading spinner and then
/// allow the user to select an opening to practice.
final class FirstViewController: UIViewController, UICollectionViewDataSource {
  
  // MARK: Overrides
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let flowLayout = UICollectionViewFlowLayout()
    flowLayout.itemSize = CGSize(width: Screen.width, height: 50)
    flowLayout.minimumLineSpacing = 5
    
    let openingSelectionCollectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
    openingSelectionCollectionView.dataSource = self
    openingSelectionCollectionView.register(OpeningCell.self, forCellWithReuseIdentifier: Constants.cellIdentifier)
    openingSelectionCollectionView.translatesAutoresizingMaskIntoConstraints = false
    
    view.addSubview(openingSelectionCollectionView)
    
    NSLayoutConstraint.activate([
      openingSelectionCollectionView.topAnchor.constraint(equalTo: view.topAnchor),
      openingSelectionCollectionView.leftAnchor.constraint(equalTo: view.leftAnchor),
      openingSelectionCollectionView.rightAnchor.constraint(equalTo: view.rightAnchor),
      openingSelectionCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
    ])
    
    self.openingSelectionCollectionView = openingSelectionCollectionView
    
    if let quizDatabase = QuizParser.getDatabase() {
      self.quizDatabase = quizDatabase
//      openingSelectionCollectionView.reloadData()
    } else {
      print("Error fetching quiz databse.")
    }
  }
  
  // MARK: UICollectionViewDataSource conformance
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return quizDatabase.openings.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.cellIdentifier, for: indexPath) as? OpeningCell else {
      print("Returning base cell")
      return UICollectionViewCell()
    }
    
    cell.configure(text: quizDatabase.openings[indexPath.item].name)
    
    return cell
  }
  
  // MARK: - Private
  
  private var quizDatabase = QuizDatabase(openings: [], quizes: [:])
  
  private weak var openingSelectionCollectionView: UICollectionView!
}
