//  Created by dasdom on 25.01.20.
//  Copyright © 2020 dasdom. All rights reserved.
//

import Foundation

extension FileManager {
  private static func documentsURL() -> URL {
    guard let url = FileManager.default.urls(
      for: .documentDirectory,
      in: .userDomainMask).first else {
        fatalError()
    }
    return url
  }
  
  static func trackURL() -> URL {
    return documentsURL().appendingPathComponent("track.gpx")
  }
}
