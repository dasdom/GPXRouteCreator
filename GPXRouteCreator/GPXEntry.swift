//  Created by dasdom on 07.02.20.
//  Copyright © 2020 dasdom. All rights reserved.
//

import Foundation
import CoreLocation

struct GPXEntry : Identifiable {
  var id = UUID()
  let coordinate: CLLocationCoordinate2D
  let date: Date
}
