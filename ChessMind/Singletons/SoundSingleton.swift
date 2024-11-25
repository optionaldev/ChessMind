//
// The ChessMind project.
// Created by optionaldev on 23/11/2024.
// Copyright © 2024 optionaldev. All rights reserved.
// 

import AVFoundation

final class SoundSingleton {
  
  static let shared = SoundSingleton()
  
  func play(_ sound: Sound) {
    players[sound.rawValue]?.play()
  }
  
  // MARK: - Private
  
  /// We have a player for each sound.
  private var players: [String: AVAudioPlayer] = [:]
  
  init() {
    for sound in Sound.allCases {
      if let soundUrl = Bundle.main.url(forResource: sound.rawValue, withExtension: "mp3") {
        do {
          let player = try AVAudioPlayer(contentsOf: soundUrl)
          player.prepareToPlay()
          players[sound.rawValue] = player
        } catch {
          print("Error trying to initalize audio player for url = \(soundUrl). Error = \(error)")
        }
      }
    }
  }
}
