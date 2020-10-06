import Foundation
import UIKit
import GoogleMaps
import GooglePlaces
import GoogleMapsUtils
import GoogleUtilities


class POIItem: NSObject, GMUClusterItem {
  var position: CLLocationCoordinate2D
  var name: String!
    

  init(position: CLLocationCoordinate2D, name: String) {
    self.position = position
    self.name = name
  }
}

final class StopMarker: GMSMarker {
    var id: Int?
    init(position: CLLocationCoordinate2D, id: Int) {
        super.init()
        self.position = position
        self.id = id
        
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        imageView.layer.cornerRadius = 15
        imageView.image = UIImage(named: "default_marker")
        self.iconView = imageView
    }
}
