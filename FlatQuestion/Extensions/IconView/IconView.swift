import UIKit

class IconView: UIView {

    @IBOutlet weak var elipseImageView: UIImageView!
    @IBOutlet weak var photoView: UIImageView!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    init(frame: CGRect, isMyFlat: Bool = false) {
        super.init(frame: frame)
        setupView()
        if isMyFlat { elipseImageView.image = UIImage(named: "Ellipse_my")}
    }

    private func loadFromNib() {
        let bundle = Bundle.init(for: type(of: self))
        let nib = UINib(nibName: "IconView", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as? UIView
        view!.frame = bounds
        view!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(view!)
    }
    
    private func setupView() {
        loadFromNib()
    }
}
