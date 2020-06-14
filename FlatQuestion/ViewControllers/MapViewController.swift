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
    //private var spacing: CGFloat = 90

    override func viewDidLoad() {
        super.viewDidLoad()
        //setupMapView()
        setupCollectionView()
        setupSearchView()
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
        //collectionView?.isPagingEnabled = true
        self.view.addSubview(collectionView ?? UICollectionView())
        self.collectionView?.delegate = self
        self.collectionView?.dataSource = self
    }

    func getFlats() {
        self.flats.append(Flat(title: "Party name here",
                               address: "st. Ulyanovskaya 8", numberOfPersons: 12, dateToCome: "Tomorrow",
                               arrayWithDescription:
            [FlatDescription(name: "Description", description: "Best party ever just click to button"),
             FlatDescription(name: "Информация", description: "Всем привет)) Если вам скучно и не знсебя заайте - потусим вместе)) мы компания из 4 человек ждем адекватных, веселых девчонок))")]))
        self.flats.append(Flat(title: "Party name here",
                           address: "st. Ulyanovskaya 8 sdsffsfsdfsf", numberOfPersons: 12, dateToCome: "Tomorrow",
                           arrayWithDescription:
        [FlatDescription(name: "Description", description: "Best party ever i seen. If u want to join us, just click to button"),
         FlatDescription(name: "Information", description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore e.")]))
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

extension MapViewController: UIScrollViewDelegate {
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        var closestCell : UICollectionViewCell = collectionView!.visibleCells[0];
        for cell in collectionView!.visibleCells as [UICollectionViewCell] {
            let closestCellDelta = abs(closestCell.center.x - collectionView!.bounds.size.width/2.0 - collectionView!.contentOffset.x)
            let cellDelta = abs(cell.center.x - collectionView!.bounds.size.width/2.0 - collectionView!.contentOffset.x)
            if (cellDelta < closestCellDelta){
                closestCell = cell
            }
        }
        let indexPath = collectionView!.indexPath(for: closestCell)
        collectionView!.scrollToItem(at: indexPath!, at: UICollectionView.ScrollPosition.centeredHorizontally, animated: true)
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
//     func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//        return spacing
//    }
//
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: 283, height: 115)
    }

//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
//        return UIEdgeInsets(top: 0, left: spacing / 2, bottom: 0, right: spacing / 2)
//    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let index = self.collectionView!.contentOffset.x / self.collectionView!.frame.size.width;
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
