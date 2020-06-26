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
    private var flats = [FlatModel]()
    private var markers = [GMSMarker]()
    private var mapView:GMSMapView?
    private var priveousSelectedIndex = 0
    private var spacing: CGFloat {
        return self.view.frame.width - 283
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupMapView()
        setupCollectionView()
        setupSearchView()
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getFlats()
    }

    override func viewWillLayoutSubviews() {
        let tabBarHeight = self.tabBarController!.tabBar.frame.size.height
        collectionView?.frame = CGRect(x: self.view.frame.origin.x,
                                       y: self.view.frame.size.height - 150 - tabBarHeight,
                                       width: self.view.frame.width, height: 115)
        collectionView?.backgroundColor = .clear
        self.view.layoutIfNeeded()
    }

    func updateFlats() {
        getFlats()
    }
    func setupSearchView() {
        let view = TopMapSearchView(frame: CGRect(x: 0, y: UIApplication.shared.statusBarFrame.height + 10, width: self.view.frame.size.width, height: 82))
        self.view.addSubview(view)
    }

    func setupCollectionView() {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView?.register(UINib(nibName: FlatCardCollectionViewCell.identifier, bundle: nil),
                                 forCellWithReuseIdentifier: FlatCardCollectionViewCell.identifier)
        collectionView?.showsHorizontalScrollIndicator = false
        collectionView?.isPagingEnabled = true
        self.view.addSubview(collectionView ?? UICollectionView())
        self.collectionView?.delegate = self
        self.collectionView?.dataSource = self
    }

    func getFlats() {
        showLoadingIndicator()
        FireBaseHelper().get { (flats) in
            self.flats = flats
            self.hideLoadingableIndicator()
            self.addMarkers(flats: self.flats)
            self.collectionView?.reloadData()
            
        }
        
    }

    func setupMapView() {
        let camera = GMSCameraPosition(latitude: 37, longitude: -122, zoom: 10)
        mapView = GMSMapView(frame: self.view.frame, camera: camera)
        mapView?.delegate = self
        guard let mapView = mapView else { return }
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

    func addModalFlatView(flat: FlatModel) {
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

extension MapViewController: UICollectionViewDelegateFlowLayout {
     func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return spacing
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: 283, height: 115)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: spacing / 2, bottom: 0, right: spacing / 2)
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let index: Int = Int(self.collectionView!.contentOffset.x / self.collectionView!.frame.size.width)
        let flat = flats[index]
        
        mapView?.animate(to: GMSCameraPosition(latitude: flat.x, longitude: flat.y, zoom: 10))
        
        let marker = markers[index]
        
        let iconView = IconView(frame: CGRect(x: 0, y: 0, width: 128, height: 128))
        
        if flat.images?.count != 0, let url = URL(string: (flat.images?.first)!) {
            iconView.photoView.sd_setImage(with: url, completed: nil)
        } else {
            iconView.photoView.image = UIImage(named: "compas")
        }
        marker.icon = UIImage(view: iconView)
        
        if priveousSelectedIndex != index {
            let marker = markers[priveousSelectedIndex]
            marker.icon = UIImage(named: "default_marker")
        }
        
        priveousSelectedIndex = index
        print(index)
    }
}

extension MapViewController: RemovableDelegate {

    func shouldRemoveFromSuperView() {
        flatModalVC.willMove(toParent: nil)
        flatModalVC.view.removeFromSuperview()
        flatModalVC.removeFromParent()
    }
}


extension MapViewController {
    func addMarkers(flats: [FlatModel]) {
        flats.map { (flat) -> () in
            addMarker(flat: flat, withTag: flats.firstIndex(where: { (flatModel) -> Bool in
                flat.id == flatModel.id
            })!)
        }
    }
    func addMarker(flat: FlatModel, withTag tag: Int) {
        DispatchQueue.main.async
        {
            var position = CLLocationCoordinate2DMake(flat.x, flat.y)
            var marker = GMSMarker(position: position)
            marker.title = flat.address
            marker.map = self.mapView
            marker.userData = tag
            marker.icon = UIImage(named: "default_marker")
            self.markers.append(marker)
            
        }
    }
}

extension MapViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        guard let index = marker.userData as? Int else { return false}
        
        let marker = markers[index]
        let flat = flats[index]
        let iconView = IconView(frame: CGRect(x: 0, y: 0, width: 128, height: 128))
        
        if flat.images?.count != 0, let url = URL(string: (flat.images?.first)!) {
            iconView.photoView.sd_setImage(with: url, completed: nil)
        } else {
            iconView.photoView.image = UIImage(named: "compas")
        }
        marker.icon = UIImage(view: iconView)
        
        if priveousSelectedIndex != index {
            let marker = markers[priveousSelectedIndex]
            marker.icon = UIImage(named: "default_marker")
        }
        
        priveousSelectedIndex = index
        
        
        collectionView?.scrollToItem(at: IndexPath(row: index, section: 0), at: .centeredHorizontally, animated: true)
        return true
    }
}


