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
  }
  
  @IBAction fileprivate func unwindToMainViewController(_ segue: UIStoryboardSegue) {}
  
}
