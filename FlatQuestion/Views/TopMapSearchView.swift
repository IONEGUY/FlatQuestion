//
//  TopMapSearchView.swift
//  FlatQuestion
//
//  Created by Андрей Олесов on 5/22/20.
//  Copyright © 2020 Андрей Олесов. All rights reserved.
//

import UIKit

class TopMapSearchView: UIView {

    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet weak var searchTextField: UITextField!
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    private func loadFromNib() {
        let bundle = Bundle.init(for: type(of: self))
        let nib = UINib(nibName: "TopMapSearchView", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as? UIView
        view!.frame = bounds
        view!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(view!)
    }
    
    private func setupView() {
        loadFromNib()
        setupFilters()
        localize()
    }
    
    private func setupFilters() {
        collectionView.register(UINib(nibName: TopMapFilterCollectionViewCell.identifier, bundle: nil),
                                forCellWithReuseIdentifier: TopMapFilterCollectionViewCell.identifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.reloadData()
        layoutIfNeeded()
    }
    
    func localize() {
        searchTextField.placeholder = "Поиск".localized
    }
}

extension TopMapSearchView: UICollectionViewDelegate {

}

extension TopMapSearchView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }

func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TopMapFilterCollectionViewCell.identifier, for: indexPath)
            as? TopMapFilterCollectionViewCell else { return UICollectionViewCell()}
        cell.setupCell(with: "Fast date date date")
        return cell
    }

}

extension TopMapSearchView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let cell: TopMapFilterCollectionViewCell = Bundle.main.loadNibNamed(TopMapFilterCollectionViewCell.identifier, owner: self, options: nil)?.first as? TopMapFilterCollectionViewCell else {
            return .zero
        }
        cell.setupCell(with: "Fast date date date")
        cell.setNeedsLayout()
        cell.layoutIfNeeded()
        let size: CGSize = cell.contentView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        return CGSize(width: size.width, height: 36)
    }
}
