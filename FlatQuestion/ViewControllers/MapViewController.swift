import UIKit
import GoogleMaps
import GooglePlaces
import GoogleMapsUtils
import GoogleUtilities
import SDWebImage
import Lottie

class MapViewController: UIViewController, CLLocationManagerDelegate, GMUClusterManagerDelegate {
    private var collectionView: UICollectionView?
    private var flatModalVC: FlatModalViewController!
    private var flats = [FlatModel]()
    private var markers = [GMSMarker]()
    private var mapView:GMSMapView?
    private var priveousSelectedIndex = -1
    private var selectedIndex = -1
    private let locationManager = CLLocationManager()
    private var clusterManager: GMUClusterManager!
    private var spacing: CGFloat {
        return self.view.frame.width - 283
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupMapView()
        setupCollectionView()
        //setupSearchView()
        setupLocationManager()
        let timer = Timer.scheduledTimer(timeInterval: 120.0, target: self, selector: #selector(fireTimer), userInfo: nil, repeats: true)
    }
    
    @objc func fireTimer() {
        getFlats(completion: nil)
    }
    
    func setupLocationManager() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    private func generateClusterItems() {
      let extent = 0.2
        for index in 0..<flats.count {
            let lat = flats[index].x
            let lng = flats[index].y
        let name = "Item \(index)"
        let item =
            POIItem(position: CLLocationCoordinate2DMake(lat, lng), name: name)
            let marker = StopMarker(position: CLLocationCoordinate2DMake(lat, lng), id: index)
        clusterManager.add(marker)
            markers.append(marker)
      }
    }

    func clusterManager(clusterManager: GMUClusterManager, didTapCluster cluster: GMUCluster) {
        let newCamera = GMSCameraPosition.camera(withTarget: cluster.position,
         zoom: mapView!.camera.zoom + 1)
       let update = GMSCameraUpdate.setCamera(newCamera)
       mapView!.moveCamera(update)
     }

     // MARK: - GMUMapViewDelegate

     func mapView(mapView: GMSMapView, didTapMarker marker: GMSMarker) -> Bool {
       if let poiItem = marker.userData as? StopMarker {
         NSLog("Did tap marker for cluster item ")
       } else {
         NSLog("Did tap a normal marker")
       }
       return false
     }
    
    /// Returns a random value between -1.0 and 1.0.
    private func randomScale() -> Double {
      return Double(arc4random()) / Double(UINT32_MAX) * 2.0 - 1.0
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
        changeCurrentLocationButtonPosition()
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


    override func viewWillAppear(_ animated: Bool) {
        if let _ = self.mapView {self.mapView!.startRendering()}
        super.viewWillAppear(animated)
        getFlats(completion: nil)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.mapView!.stopRendering()
        self.navigationController?.navigationBar.isHidden = false
    }

    override func viewWillLayoutSubviews() {
        let tabBarHeight = self.tabBarController!.tabBar.frame.size.height
        collectionView?.frame = CGRect(x: self.view.frame.origin.x,
                                       y: self.view.frame.size.height - 150 - tabBarHeight,
                                       width: self.view.frame.width, height: 115)
        collectionView?.backgroundColor = .clear
        collectionView?.isPagingEnabled = true
        self.view.layoutIfNeeded()
    }
    
    func changeCurrentLocationButtonPosition() {
        for object in self.mapView!.subviews{
            if(object.theClassName == "GMSUISettingsPaddingView"){
                for view in object.subviews{
                    if(view.theClassName == "GMSUISettingsView"){
                        for btn in view.subviews{
                            if(btn.theClassName == "GMSx_QTMButton"){
                                var frame = btn.frame
                                frame.origin.y = (self.collectionView?.frame.origin.y)! - 150
                                btn.frame = frame
                                self.view.layoutIfNeeded()
                                
                            }
                        }
                    }
                }
            }
        }
    }
    

    func updateFlats() {
        getFlats(completion: nil)
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
        self.view.addSubview(collectionView ?? UICollectionView())
        self.collectionView?.delegate = self
        self.collectionView?.dataSource = self
    }

    func getFlats(completion : (()->())?) {
        DispatchQueue.global(qos: .userInteractive).async {
            FireBaseHelper().get { (flats) in
                DispatchQueue.main.async {
                    self.flats = flats
                    UIView.animate(withDuration: 0, delay: 0, options: .allowAnimatedContent, animations: {
                        self.collectionView?.reloadData()
                    }) { (finished) in
                        completion?()
                    }
                    self.initClustering()
                    
                }
            }
        }
    }
    
    func openFlatWith(id: Int) {
        getFlats {
            DispatchQueue.main.async {
                self.collectionView?.scrollToItem(at: self.getIndexOfFlatById(id: id), at: .centeredHorizontally, animated: true)
            }
        }
    }
    
    func getIndexOfFlatById(id: Int) -> IndexPath {
        let index = self.flats.firstIndex { (flat) -> Bool in
            return flat.id == id
            } ?? 0
        return IndexPath(item: index, section: 0)
    }

    func initClustering() {
        let iconGenerator = GMUDefaultClusterIconGenerator()
           let algorithm = GMUNonHierarchicalDistanceBasedAlgorithm()
        let renderer = GMUDefaultClusterRenderer(mapView: self.mapView!,
                                       clusterIconGenerator: iconGenerator)
        renderer.delegate = self
        self.clusterManager = GMUClusterManager(map: self.mapView!, algorithm: algorithm,
                                                             renderer: renderer)
        self.clusterManager.clearItems()
        self.generateClusterItems()
        self.clusterManager.cluster()
        self.clusterManager.setDelegate(self, mapDelegate: self)
    }
    
    func setupMapView() {
        let camera = GMSCameraPosition(latitude: 37, longitude: -122, zoom: 10)
        mapView = GMSMapView(frame: self.view.frame, camera: camera)
        mapView?.delegate = self
        mapView?.isMyLocationEnabled = true
        self.mapView!.padding = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
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
        guard let barVC = tabBarController as? MainTabBarController else { return }
        barVC.setTabBarVisible(visible: false, duration: 0.3, animated: true)
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
        self.mapView!.stopRendering()
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
        selectedIndex = Int(self.collectionView!.contentOffset.x / self.collectionView!.frame.size.width)
        let flat = flats[selectedIndex]
        
        mapView?.animate(to: GMSCameraPosition(latitude: flat.x, longitude: flat.y, zoom: 25))
        
        self.clusterManager.cluster()
        print(index)
    }
}

extension MapViewController: RemovableDelegate {
    func shouldOpenProfileVC(vc: UIViewController) {
        guard let barVC = tabBarController as? MainTabBarController else { return }
        barVC.setTabBarVisible(visible: true, duration: 0.2, animated: true)
        changeCurrentLocationButtonPosition()
        UIView.animate(withDuration: 0.1, animations: {
            self.flatModalVC.willMove(toParent: nil)
            self.flatModalVC.view.removeFromSuperview()
            self.flatModalVC.removeFromParent()
        }) { (finished) in
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        //self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func shouldOpenFlatVC(vc: UIViewController) {
        guard let barVC = tabBarController as? MainTabBarController else { return }
        barVC.setTabBarVisible(visible: true, duration: 0.2, animated: true)
        changeCurrentLocationButtonPosition()
        UIView.animate(withDuration: 0.1, animations: {
            self.flatModalVC.willMove(toParent: nil)
            self.flatModalVC.view.removeFromSuperview()
            self.flatModalVC.removeFromParent()
        }) { (finished) in
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        //self.navigationController?.pushViewController(vc, animated: true)
    }
    

    func shouldRemoveFromSuperView() {
        guard let barVC = tabBarController as? MainTabBarController else { return }
        barVC.setTabBarVisible(visible: true, duration: 0.2, animated: true)
        changeCurrentLocationButtonPosition()
        self.mapView!.startRendering()
        flatModalVC.willMove(toParent: nil)
        flatModalVC.view.removeFromSuperview()
        flatModalVC.removeFromParent()
    }
}

extension MapViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        guard let markerData = marker.userData as? StopMarker else { return false}
        
        selectedIndex = markerData.id!
        collectionView?.scrollToItem(at: IndexPath(row: selectedIndex, section: 0), at: .centeredHorizontally, animated: true)
        clusterManager.cluster()
        return true
    }
}


extension MapViewController: GMUClusterRendererDelegate {
    func renderer(_ renderer: GMUClusterRenderer, willRenderMarker marker: GMSMarker) {
        guard UserSettings.appUser != nil else { return }
        var lottieView: AnimationView!
        lottieView = AnimationView(name: "marker-lottie2")
        
        if  let markerData = (marker.userData as? StopMarker) {
                priveousSelectedIndex = selectedIndex
            let flat = flats[markerData.id!]
                if flat.userId == UserSettings.appUser?.id {
                    lottieView = AnimationView(name: "marker-lottie-my2")
                }


            lottieView.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
            marker.iconView = lottieView
            marker.groundAnchor = CGPoint(x: 0.5, y: 0.67)
            lottieView.loopMode = .autoReverse
            lottieView.contentMode = .scaleAspectFill
            lottieView.play()
        }
    }
    
//    func renderer(_ renderer: GMUClusterRenderer, willRenderMarker marker: GMSMarker) {
//
//        var imageView = UIImageView(image: UIImage(named: "default_marker"))
//        if  let markerData = (marker.userData as? StopMarker) {
//                priveousSelectedIndex = selectedIndex
//            let flat = flats[markerData.id!]
//                if flat.userId == UserSettings.appUser!.id {
//                    imageView = UIImageView(image: UIImage(named: "my_marker"))
//                }
//            marker.iconView = imageView
//            marker.tracksViewChanges = false
//        }
//    }

//    func renderer(_ renderer: GMUClusterRenderer, willRenderMarker marker: GMSMarker) {
//        if  let markerData = (marker.userData as? StopMarker) {
//
//            if markerData.id == selectedIndex {
//                priveousSelectedIndex = selectedIndex
//                let flat = flats[selectedIndex]
//                let iconView: IconView
//                if flat.userId == UserSettings.appUser!.id {
//                    iconView = IconView(frame: CGRect(x: -64, y: -64, width: 128, height: 128), isMyFlat: true)
//                } else {
//                    iconView = IconView(frame: CGRect(x: -64, y: -64, width: 128, height: 128))
//                }
//
//                if flat.images?.count != 0, let url = URL(string: (flat.images?.first)!) {
//                    iconView.photoView.sd_imageIndicator = SDWebImageActivityIndicator.gray
//                    iconView.photoView.sd_setImage(with: url, completed: nil)
//                } else {
//                    iconView.photoView.image = UIImage(named: "compas")
//                }
//                marker.icon = UIImage(view: iconView)
//
//            } else {
//                let flat = flats[markerData.id!]
//                marker.icon = flat.userId == UserSettings.appUser!.id ? UIImage(named: "my_marker") : UIImage(named: "default_marker")
//
//            }
//        }
//
//    }
        
}
public extension NSObject {
public var theClassName: String {
    return NSStringFromClass(type(of: self))
}
}
