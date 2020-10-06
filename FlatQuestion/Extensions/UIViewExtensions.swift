import UIKit

extension UIView {
    func addShadow(shadowColor: CGColor, shadowOffset: CGSize, shadowOpacity: Float, shadowRadius: CGFloat) {
        layer.shadowColor = shadowColor
        layer.shadowOffset = shadowOffset
        layer.shadowOpacity = shadowOpacity
        layer.shadowRadius = shadowRadius
    }
    
    func applyGradient(colours: [UIColor]) {
        self.applyGradient(colours: colours, locations: nil)
    }

    func applyGradient(colours: [UIColor], locations: [NSNumber]?) {
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = colours.map { $0.cgColor }
        gradient.locations = locations
        gradient.cornerRadius = 20
        layer.insertSublayer(gradient, at: 0)
    }
    
    func applyRoundedStyle(_ cornerRadius: CGFloat = 5) {
        self.backgroundColor = .clear
        self.layer.cornerRadius = cornerRadius
        self.layer.borderWidth = 0
        self.layer.borderColor = UIColor.clear.cgColor
    }
    
    func applyShadow(_ color: UIColor = UIColor.gray, _ cornerRadius: CGFloat = 25,
                     shadowOffsetHeight: CGFloat = 20) {
        self.layer.cornerRadius = cornerRadius
        self.addShadow(shadowColor: color.cgColor,
                         shadowOffset: CGSize(width: 0, height: shadowOffsetHeight),
                         shadowOpacity: 0.3,
                         shadowRadius: 20.0)
    }
    
    func applyMargin(_ insets: UIEdgeInsets) {
        self.frame = self.frame.inset(by: insets)
    }
    
    func applyCircledStyle() {
        self.layer.cornerRadius = self.frame.height / 2
    }
}
