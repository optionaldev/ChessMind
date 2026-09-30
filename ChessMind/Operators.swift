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

func + (lhs: NSAttributedString, rhs: NSAttributedString) -> NSAttributedString {
    let result = NSMutableAttributedString(attributedString: lhs)
    
    result.append(rhs)
    
    return result
}
