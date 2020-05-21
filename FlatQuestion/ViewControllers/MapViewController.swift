//
//  MapViewController.swift
//  FlatQuestion
//
//  Created by Андрей Олесов on 5/13/20.
//  Copyright © 2020 Андрей Олесов. All rights reserved.
//

import UIKit
import GoogleMaps

class MapViewController: UIViewController {
    private var collectionView: UICollectionView?
    private var flatModalVC: FlatModalViewController!
    private var flats = [Flat]()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupMapView()
        setupCollectionView()
        getFlats()
    }

    override func viewWillLayoutSubviews() {
        let tabBarHeight = self.tabBarController!.tabBar.frame.size.height
        collectionView?.frame = CGRect(x: self.view.frame.origin.x,
                                       y: self.view.frame.size.height - 130 - tabBarHeight,
                                       width: self.view.frame.width, height: 115)
        collectionView?.backgroundColor = .clear
        self.view.layoutIfNeeded()
    }

    func setupCollectionView() {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.estimatedItemSize = CGSize(width: 275, height: 150)
        layout.scrollDirection = .horizontal
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView?.register(UINib(nibName: FlatCardCollectionViewCell.identifier, bundle: nil),
                                 forCellWithReuseIdentifier: FlatCardCollectionViewCell.identifier)
        collectionView?.showsHorizontalScrollIndicator = false
        self.view.addSubview(collectionView ?? UICollectionView())
        self.collectionView?.delegate = self
        self.collectionView?.dataSource = self
    }

    func getFlats() {
        self.flats.append(Flat(title: "Party name here",
                               address: "st. Ulyanovskaya 8", numberOfPersons: 12, dateToCome: "Tomorrow",
                               arrayWithDescription:
            [FlatDescription(name: "Description", description: "Best party ever i seen. If u want to join us, just click to button"),
             FlatDescription(name: "Information", description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore e.Lorem ipsum dolor sit amet")]))
        self.flats.append(Flat(title: "Party name here",
                           address: "st. Ulyanovskaya 8", numberOfPersons: 12, dateToCome: "Tomorrow",
                           arrayWithDescription:
        [FlatDescription(name: "Description", description: "Best party ever i seen. If u want to join us, just click to button"),
         FlatDescription(name: "Information", description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore e.")]))
        self.flats.append(Flat(title: "Party name here",
                           address: "st. Ulyanovskaya 8", numberOfPersons: 12, dateToCome: "Tomorrow",
                           arrayWithDescription:
        [FlatDescription(name: "Description", description: "Best party ever i seen. If u want to join us, just click to button"),
         FlatDescription(name: "Information", description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore e.")]))
    }

    func setupMapView() {
        let camera = GMSCameraPosition(latitude: 37, longitude: -122, zoom: 10)
        let mapView = GMSMapView(frame: self.view.frame, camera: camera)
        do {
            if let styleURL = Bundle.main.url(forResource: "map", withExtension: "json") {
                mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
            } else {
                NSLog("Unable to find style.json")
            }
        } catch {
            NSLog("One or more of the map styles failed to load. \(error)")
        }
        self.view.addSubview(mapView)
    }

    func addModalFlatView(flat: Flat) {
        flatModalVC = FlatModalViewController(nibName: "FlatModalViewController", bundle: nil)
        flatModalVC.flat = flat
        flatModalVC.delegate = self
        self.addChild(flatModalVC)
        self.view.addSubview(flatModalVC.view)
        flatModalVC.didMove(toParent: self)
        let height = view.frame.height
        let width  = view.frame.width
        flatModalVC.view.frame = CGRect(x: 0, y: view.frame.maxY, width: width, height: height)
    }
}

extension MapViewController: UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.flats.count
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        addModalFlatView(flat: self.flats[indexPath.item])
    }
}

extension MapViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let flatCell = self.collectionView?
            .dequeueReusableCell(withReuseIdentifier: FlatCardCollectionViewCell.self.identifier,
                                                                for: indexPath) as? FlatCardCollectionViewCell
        guard let cell = flatCell else {return UICollectionViewCell()}
        cell.fillCellData(with: self.flats[indexPath.item])
        return cell
    }
}

extension MapViewController: RemovableDelegate {
    func shouldRemoveFromSuperView() {
        flatModalVC.willMove(toParent: nil)
        flatModalVC.view.removeFromSuperview()
        flatModalVC.removeFromParent()
    }
}
