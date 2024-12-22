//
// The ChessMind project.
// Created by optionaldev on 22/12/2024.
// Copyright © 2024 optionaldev. All rights reserved.
// 

import UIKit

extension UICollectionView {
  
  func register<T: UICollectionViewCell>(cellClass: T.Type) {
    self.register(cellClass, forCellWithReuseIdentifier: "\(cellClass)")
  }
  
  func dequeu<T: UICollectionViewCell>(cellClass: T.Type, indexPath: IndexPath) -> T {
    return dequeueReusableCell(withReuseIdentifier: "\(cellClass)", for: indexPath) as! T
  }
}
