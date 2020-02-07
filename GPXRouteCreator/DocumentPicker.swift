//  Created by dasdom on 07.02.20.
//  Copyright © 2020 dasdom. All rights reserved.
//

import UIKit
import SwiftUI

final class DocumentPicker : NSObject, UIViewControllerRepresentable {
  
  let url: URL
  
  init(url: URL) {
    
    self.url = url
    
    super.init()
  }
  
  func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
    UIDocumentPickerViewController(url: url, in: .exportToService)
  }
  
  func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {
    
  }
}
