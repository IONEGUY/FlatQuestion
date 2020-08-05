//
//  MainTabBarController.swift
//  FlatQuestion
//
//  Created by Андрей Олесов on 6/15/20.
//  Copyright © 2020 Андрей Олесов. All rights reserved.
//

import Foundation

import UIKit

class MainTabBarController: UITabBarController {
  
  @IBOutlet weak var centerButton: UIButton!

  override func viewDidLoad() {
    super.viewDidLoad()
  }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupCenterButton()
    }

    
  fileprivate func setupCenterButton() {
    tabBar.addSubview(centerButton)
    centerButton.translatesAutoresizingMaskIntoConstraints = false
    centerButton.centerYAnchor.constraint(equalTo: tabBar.topAnchor).isActive = true
    centerButton.centerXAnchor.constraint(equalTo: tabBar.centerXAnchor).isActive = true
    guard let customTabbar = tabBar as? MainMenuTabBar else { return }
    customTabbar.centerButton = centerButton
    customTabbar.centerButton?.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
  }

    @objc func buttonAction(sender: UIButton!) {
        let vc = storyboard!.instantiateViewController(withIdentifier: "CreateFlatViewController") as! CreateFlatViewController
        vc.delegate = self
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: true, completion: nil)
       }
    
  @IBAction fileprivate func unwindToMainViewController(_ segue: UIStoryboardSegue) {}

}

extension MainTabBarController: CreateFlatProtocol {
    func flatWasCreated() {
        let topVC = topMostViewController()
        switch topVC {
        case is MapViewController:
            let vc = topVC as? MapViewController
            vc?.updateFlats()
        case is ProfileViewController:
            let vc = topVC as? ProfileViewController
            vc?.setupData()
        default: break
        }
    }
    
}

