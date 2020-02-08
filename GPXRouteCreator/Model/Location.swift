//
//  Location.swift
//  GPXRouteCreator
//
//  Created by Oliver Epper on 08.02.20.
//  Copyright © 2020 dasdom. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit

struct Location: Identifiable {
    var id: Int
    var coordinate: CLLocationCoordinate2D
    var date: Date

    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        return formatter
    }()

    var pointAnnotation: MKPointAnnotation {
        get {
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = String(id)

            return annotation
        }
    }

    var gpx: String {
        #"""
        <wpt lat="\#(coordinate.latitude)" lon="\#(coordinate.longitude)">
        <time>\#(Location.dateFormatter.string(from: date))</time>
        </wpt>
        """#
    }
}
