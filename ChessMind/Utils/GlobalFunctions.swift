//
// The ChessMind project.
// Created by optionaldev on 22/12/2024.
// Copyright © 2024 optionaldev. All rights reserved.
// 

import Foundation

func * (lhs: Int, rhs: CGFloat) -> CGFloat {
  return CGFloat(lhs) * rhs
}

func * (lhs: CGFloat, rhs: Int) -> CGFloat {
  return lhs * CGFloat(rhs)
}
