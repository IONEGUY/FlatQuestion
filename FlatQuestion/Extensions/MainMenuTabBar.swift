import UIKit

class MainMenuTabBar: UITabBar {

  var centerButton: UIButton?

  override func point(inside point: CGPoint, with _: UIEvent?) -> Bool {
    if let centerButton = centerButton {
      if centerButton.frame.contains(point) {
        return true
      }
    }

    return self.bounds.contains(point)
  }

}
