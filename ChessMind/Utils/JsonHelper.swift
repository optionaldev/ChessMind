//
// The ChessMind project.
// Created by optionaldev on 28/12/2024.
// Copyright © 2024 optionaldev. All rights reserved.
//

import Foundation

enum JsonHelper {
  
  static func json<T: Decodable>(_: T.Type, fromFile fileFullName: String) -> T? {
    let fileComponents = fileFullName.split(separator: ".").map { String($0) }
    
    guard fileComponents.count == 2 else {
      print("Currently, file names with more than one period is not supported. \"\(fileFullName)\"")
      return nil
    }
    
    guard let fileName = fileComponents.first,
          let fileExtension = fileComponents.last else
    {
      print("Should have two components, what happened? \"\(fileComponents)\"")
      return nil
    }
    
    guard let url = Bundle.main.url(forResource: fileName,
                                    withExtension: fileExtension) else {
      print("Failed to find file with name = \(fileName) and extension = \(fileExtension).")
      return nil
    }
    
    let jsonData: Data
    do {
      jsonData = try Data(contentsOf: url)
    } catch {
      print("Failed to get data from url = \(url) error = \(error)")
      return nil
    }
    
    let decodable: T
    do {
      decodable = try JSONDecoder().decode(T.self, from: jsonData)
      return decodable
    } catch {
      print("Decoding json data with count = \(jsonData.count) failed \(error)")
      return nil
    }
  }
}
