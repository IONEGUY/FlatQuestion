//
//  AppDelegate.swift
//  FlatQuestion
//
//  Created by Андрей Олесов on 5/13/20.
//  Copyright © 2020 Андрей Олесов. All rights reserved.
//

import UIKit
import GoogleMaps
import Firebase
import IQKeyboardManagerSwift
import GooglePlaces
import SDWebImage
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {        
        setupGoogleAPIs()
        FirebaseApp.configure()
        IQKeyboardManager.shared.enable = true        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        print("url")
        return false
    }
    

    private func setupGoogleAPIs() {
        GMSPlacesClient.provideAPIKey("AIzaSyCmJ1VuRvdCDWlwOy1JqnY6y8cQmV1MTxs")
        GMSServices.provideAPIKey("AIzaSyCmJ1VuRvdCDWlwOy1JqnY6y8cQmV1MTxs")
    }
}
