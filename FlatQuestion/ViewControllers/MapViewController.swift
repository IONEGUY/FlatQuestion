//
//  MapViewController.swift
//  FlatQuestion
//
//  Created by Андрей Олесов on 5/13/20.
//  Copyright © 2020 Андрей Олесов. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces

class MapViewController: UIViewController, CLLocationManagerDelegate {
    private var collectionView: UICollectionView?
    private var flatModalVC: FlatModalViewController!
    private var flats = [FlatModel]()
    private var markers = [GMSMarker]()
    private var mapView:GMSMapView?
    private var priveousSelectedIndex = 0
    private let locationManager = CLLocationManager()
    private var spacing: CGFloat {
        return self.view.frame.width - 283
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupMapView()
        setupCollectionView()
        setupSearchView()
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            let camera = GMSCameraPosition.camera(withLatitude: (location.coordinate.latitude), longitude: (location.coordinate.longitude), zoom: 17.0)

            self.mapView?.animate(to: camera)
           self.locationManager.stopUpdatingLocation()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        checkAccess()
    }

    @objc func didBecomeActive() {
        checkAccess()
    }
    
    
    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
        checkAccess()
        return false
    }
    
    func checkAccess() {
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
                case .notDetermined, .restricted:
                    locationManager.delegate = self
                    locationManager.requestWhenInUseAuthorization()
                    print("No access")
            case .denied: showAlertWithMessage(message: "Доступ к геолокации запрещен".localized)
                                self.mapView?.isMyLocationEnabled = false;
                case .authorizedAlways, .authorizedWhenInUse:
                    self.mapView?.isMyLocationEnabled = true;
                    print("Access")
                @unknown default:
                break
            }
            } else {
                print("Location services are not enabled")
        }
    }
    
    func showAlertWithMessage(message: String) {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        let alert = UIAlertController(title: "Ошибка".localized, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Отмена".localized, style: .cancel) { (action) in
            alert.dismiss(animated: true, completion: nil)
        }
        let settingsAction = UIAlertAction(title: "Настройки".localized, style: .default) { (action) in
            alert.dismiss(animated: true, completion: nil)
            UIApplication.shared.open(settingsUrl, options: [:]) { (success) in
                if success {
                    print("Settings opened: \(success)")
                }
            }
        }
        alert.addAction(cancelAction)
        alert.addAction(settingsAction)
        self.present(alert, animated: true, completion: nil)
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
        mapView?.isMyLocationEnabled = true
        mapView!.settings.myLocationButton = true
        mapView!.settings.compassButton = true
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
        let flat = self.flats[indexPath.item]
        cell.fillCellData(with: flat)
        if let flats = UserSettings.appUser.flats, flats.contains(flat.id) {
            cell.backgroundColor = .yellow
        }
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


