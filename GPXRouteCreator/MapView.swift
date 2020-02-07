//  Created by dasdom on 07.02.20.
//  Copyright © 2020 dasdom. All rights reserved.
//

import SwiftUI
import UIKit
import MapKit

struct MapView : UIViewRepresentable {
  
  // Tap handling from https://stackoverflow.com/a/56518293/498796
  var tappedCallback: ((CLLocationCoordinate2D) -> Void)
  @Binding var gpxEntries: [GPXEntry]
  let delegate = MapViewDelegate()
  
  func makeUIView(context: Context) -> MKMapView {
    let mapView = MKMapView()
    let longPressGesture = UITapGestureRecognizer(target: context.coordinator,
                                                       action: #selector(Coordinator.addLocation))
    
    mapView.addGestureRecognizer(longPressGesture)
    return mapView
  }
  
  func updateUIView(_ mapView: MKMapView, context: Context) {
    mapView.removeOverlays(mapView.overlays)
    let coordinates = gpxEntries.map({ $0.coordinate })
    let overlay = MKPolyline(coordinates: coordinates,
                             count: coordinates.count)
    mapView.delegate = delegate
    mapView.addOverlay(overlay)
  }
  
  class Coordinator : NSObject {
    var tappedCallback: ((CLLocationCoordinate2D) -> Void)

    init(tappedCallback: @escaping ((CLLocationCoordinate2D) -> Void)) {
      self.tappedCallback = tappedCallback
    }

    @objc func addLocation(_ sender: UITapGestureRecognizer) {
      
      print("sender state: \(sender.state)")
//      if sender.state == .began {
        let point = sender.location(in: sender.view)
        if let mapView = sender.view as? MKMapView {
          let coordinate = mapView.convert(point, toCoordinateFrom: mapView)
          tappedCallback(coordinate)
        }
//      }
    }
  }
  
  func makeCoordinator() -> Coordinator {
    Coordinator(tappedCallback: tappedCallback)
  }
}

class MapViewDelegate : NSObject, MKMapViewDelegate {
  func mapView(_ mapView: MKMapView,
               rendererFor overlay: MKOverlay)
    -> MKOverlayRenderer {

      if overlay is MKPolyline {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = .red
        renderer.lineWidth = 3
        return renderer
      } else {
        return MKOverlayRenderer(overlay: overlay)
      }
  }
}

