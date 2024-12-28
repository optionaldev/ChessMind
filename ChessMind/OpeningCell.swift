//
// The ChessMind project.
// Created by optionaldev on 21/12/2024.
// Copyright © 2024 optionaldev. All rights reserved.
// 

import UIKit

protocol OpeningDelegate: AnyObject {
  
  func didSelect(opening: Opening, lineIndex: Int)
}

final class OpeningCell: UICollectionViewCell, UICollectionViewDataSource, UICollectionViewDelegate {
  
  weak var delegate: OpeningDelegate?
  
  func configure(opening: Opening, isExpanded: Bool) {
    self.opening = opening
    nameLabel.text = opening.name
    self.isExpanded = isExpanded
  }
  
  // MARK: Init
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    // Maybe also add an icon for the opening, something representative.
    
    let nameLabel = CustomLabel(fontSize: Constants.openingLabelFontSize)
    
    let flowLayout = UICollectionViewFlowLayout()
    flowLayout.itemSize = CGSize(width: Screen.width, height: Constants.lineHeight)
    flowLayout.minimumLineSpacing = Constants.lineCollectionSpacing
    
    let linesCollectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
    linesCollectionView.backgroundColor = .clear
    linesCollectionView.dataSource = self
    linesCollectionView.delegate = self
    linesCollectionView.register(cellClass: LineCell.self)
    linesCollectionView.translatesAutoresizingMaskIntoConstraints = false
    
    contentView.addSubview(linesCollectionView)
    contentView.addSubview(nameLabel)
    contentView.backgroundColor = UIColor.darkSquareColor
    
    NSLayoutConstraint.activate([
      nameLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
      nameLabel.topAnchor.constraint(equalTo: topAnchor, constant: Constants.openingLabelPadding),
      
      linesCollectionView.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: Constants.openingLabelPadding),
      linesCollectionView.leftAnchor.constraint(equalTo: leftAnchor),
      linesCollectionView.rightAnchor.constraint(equalTo: rightAnchor),
      linesCollectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
    ])
    
    self.linesCollectionView = linesCollectionView
    self.nameLabel = nameLabel
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: UICollectionViewDataSource conformance
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return opening.lines.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let line = opening.lines[indexPath.item]
    let cell = collectionView.dequeu(cellClass: LineCell.self, indexPath: indexPath)
    
    cell.configure(text: line.name)
    
    return cell
  }
  
  // MARK: UICollectionViewDelegate conformance
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    delegate?.didSelect(opening: opening, lineIndex: indexPath.item)
  }
  
  // MARK: - Private
  
  private var isExpanded: Bool = false
  private var opening: Opening!
  
  private weak var linesCollectionView: UICollectionView!
  private weak var nameLabel: CustomLabel!
}
