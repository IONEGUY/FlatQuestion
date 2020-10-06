import Foundation
import UIKit

class BlueButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    func setup() {
        self.backgroundColor = UIColor(hex: 0x03CCE0)
        self.titleLabel?.textColor = .white
        
        self.addShadow(shadowColor: UIColor(hex: 0x03CCE0).cgColor,
                         shadowOffset: CGSize(width: 5, height: 10),
                         shadowOpacity: 0.2,
                         shadowRadius: 10.0)
    }
}
