//  Created by dasdom on 07.02.20.
//  Copyright © 2020 dasdom. All rights reserved.
//

import SwiftUI
import CoreLocation

struct ContentView: View {
  
  @State private var locations: [Location] = []
  @State private  var tappedCoordinate: CLLocationCoordinate2D? {
    didSet {
      if let coordinate = tappedCoordinate {
        coordinateString = "\(coordinate.latitude), \(coordinate.longitude)"
      }
    }
  }
  @State private var coordinateString = "Tap a location you like to add."
  @State private var addTime = false
  @State private var showDocumentsPicker = false
  @State private var secondsBetween = 60
  private var timeDiffText: String {
    var strings: [String] = []
    let minutes = secondsBetween / 60
    let seconds = secondsBetween % 60
    if minutes > 0 {
      strings.append("\(minutes) min")
    }
    if seconds > 0 {
      strings.append("\(seconds) s")
    }
    return strings.joined(separator: " ")
  }
  
  static let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
  }()

  var body: some View {
    GeometryReader { geometry in
      HStack {
        ZStack(alignment: .bottomTrailing) {
          MapView(tappedCallback: { coordinate in
            self.tappedCoordinate = coordinate
            self.add(coordinate: coordinate)
          }, locations: self.$locations)
          
          VStack(alignment: .center, spacing: 10) {
            Text(self.coordinateString)
            Stepper(onIncrement: {
              if self.secondsBetween >= 120 {
                self.secondsBetween += 60
              } else {
                self.secondsBetween += 10
              }
            }, onDecrement: {
              if self.secondsBetween <= 10 {
                self.secondsBetween -= 1
              } else if self.secondsBetween < 0 {
                self.secondsBetween = 0
              } else {
                self.secondsBetween -= 10
              }
            }) {
              Text("\(self.timeDiffText) to previous entry")
            }
          }
          .padding()
          .frame(width: 400)
          .background(Color(UIColor.systemBackground.withAlphaComponent(0.7)))
          
        }
        VStack {
          //        NavigationView {
          List {
            ForEach(self.locations) { location in
              VStack {
                Text("\(location.coordinate.latitude), \(location.coordinate.longitude)")
                Text("\(ContentView.dateFormatter.string(from: location.date))")
              }
              .foregroundColor(Color(UIColor.label))
              .onLongPressGesture {
                if let index = self.locations.firstIndex(where: { (temp) -> Bool in
                  temp.date == location.date
                }) {
                  self.locations.remove(at: index)
                }
              }
            }
//            .onMove { from, to in
//              print("from: \(from), to: \(to)")
//              self.locations.move(fromOffsets: from, toOffset: to)
//            }
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
  
  func add(coordinate: CLLocationCoordinate2D) {
    let lastDate = self.locations.last?.date ?? Date()
    let date = Date(timeInterval: TimeInterval(self.secondsBetween), since: lastDate)
    locations.append(Location(id: locations.count + 1,
                              coordinate: coordinate,
                              date: date))
}
  
  func export() {
    var exportStrings: [String] = ["<?xml version=\"1.0\"?>"]
    exportStrings.append("<gpx version=\"1.1\" creator=\"GPXRouteCreator\">")
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"

    locations.forEach { location in
        exportStrings.append(location.gpx)
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
