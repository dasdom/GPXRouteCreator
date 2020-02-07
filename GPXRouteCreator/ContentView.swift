//  Created by dasdom on 07.02.20.
//  Copyright © 2020 dasdom. All rights reserved.
//

import SwiftUI
import CoreLocation

struct ContentView: View {
  
  let tap = TapGesture()
  @State var gpxEntries: [GPXEntry] = []
  @State var tappedCoordinate: CLLocationCoordinate2D? {
    didSet {
      if let coordinate = tappedCoordinate {
        coordinateString = "\(coordinate.latitude), \(coordinate.longitude)"
      }
    }
  }
  @State var coordinateString = "Tap a location you like to add."
  @State var addTime = false
  @State var minutesBetween = 5
  @State var showDocumentsPicker = false
  let dateFormatter: DateFormatter
  
  init() {
    dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .short
    dateFormatter.timeStyle = .short
  }
  
  var body: some View {
    GeometryReader { geometry in
      HStack {
        ZStack(alignment: .bottomTrailing) {
          MapView(tappedCallback: { coordinate in
            self.tappedCoordinate = coordinate
          }, gpxEntries: self.$gpxEntries)
          
          VStack(alignment: .center, spacing: 10) {
            Text(self.coordinateString)
            Stepper(onIncrement: {
              self.minutesBetween += 1
            }, onDecrement: {
              self.minutesBetween -= 1
            }) {
              Text("\(self.minutesBetween) min to last")
            }
            Button("Add") {
              if let coordinate = self.tappedCoordinate {
                let lastDate = self.gpxEntries.last?.date ?? Date()
                let date = Date(timeInterval: TimeInterval(self.minutesBetween*60), since: lastDate)
                self.gpxEntries.append(GPXEntry(coordinate: coordinate, date: date))
              }
            }
          }
          .padding()
          .frame(width: 400)
          .background(Color(UIColor.systemBackground.withAlphaComponent(0.7)))
          
        }
        VStack {
          //        NavigationView {
          List(self.gpxEntries) { entry in
            VStack {
              Text("\(entry.coordinate.latitude), \(entry.coordinate.longitude)")
              Text("\(self.dateFormatter.string(from: entry.date))")
            }
            .foregroundColor(Color(UIColor.label))
          }
          HStack {
            Button(action: {
              self.export()
              self.showDocumentsPicker = true
              #if targetEnvironment(macCatalyst)
              UIApplication.shared.windows[0].rootViewController!.present(UIDocumentPickerViewController(url: FileManager.trackURL(), in: .exportToService), animated: true)
              #endif
            }) { Image(systemName: "square.and.arrow.up") }
          }
          .padding()
        }
        .frame(width: geometry.size.width*0.3)
      }
        .overlay(
          VStack {
            if self.showDocumentsPicker {
              DocumentPicker(url: FileManager.trackURL())
            } else {
              EmptyView()
            }
          }
      )
    }
  }
  
  func export() {
    var exportStrings: [String] = ["<?xml version=\"1.0\"?>"]
    exportStrings.append("<gpx version=\"1.1\" creator=\"GPXRouteCreator\">")
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
    
    for gpxEntry in gpxEntries {
      exportStrings.append("  <wpt lat=\"\(gpxEntry.coordinate.latitude)\" lon=\"\(gpxEntry.coordinate.longitude)\">")
      exportStrings.append("    <time>\(dateFormatter.string(from: gpxEntry.date))</time>")
      exportStrings.append("  </wpt>")
    }
    
    exportStrings.append("\n</gpx>")
    
    let data = exportStrings.joined(separator: "\n").data(using: .utf8)
    let url = FileManager.trackURL()
    do {
      try data?.write(to: url)
      print("did write to \(url)")
    } catch {
      print("error: \(error)")
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
