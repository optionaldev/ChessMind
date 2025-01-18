//
//  Operators.swift
//  ChessMind
//
//  Created by Alexandru Pavalache on 18.01.2025.
//

import Foundation

func + (lhs: NSAttributedString, rhs: String) -> NSAttributedString {
  let result = NSMutableAttributedString(attributedString: lhs)
  
  let attributedRhs = NSAttributedString(string: rhs)
  result.append(attributedRhs)
  
  return result
}
