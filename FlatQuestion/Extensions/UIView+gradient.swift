import Foundation
import UIKit

extension UIView {
    @discardableResult
    func applyGradientV2(colours: [UIColor], removeTopCorners: Bool = false) -> CAGradientLayer {
        return self.applyGradientV2(colours: colours, locations: nil, removeTopCorners: removeTopCorners)
    }

    @discardableResult
    func applyGradientV2(colours: [UIColor], locations: [NSNumber]?, removeTopCorners: Bool = false) -> CAGradientLayer {
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = colours.map { $0.cgColor }
        gradient.locations = locations
        gradient.cornerRadius = self.layer.cornerRadius
        if removeTopCorners {gradient.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]}
        self.layer.insertSublayer(gradient, at: 0)
        return gradient
        
    }
    
    func removeSublayers() {
        guard let allSublayers = self.layer.sublayers else { return }
        allSublayers.forEach { (layer) in
            if layer is CAGradientLayer {
                layer.removeFromSuperlayer()
            }
        }
        layer.cornerRadius = 0
        clipsToBounds = false
    }
}
