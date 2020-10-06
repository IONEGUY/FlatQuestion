//
//  WRGImageGallery.swift
//  WRGImageGallery
//
//  Created by Mujeeb R. O on 11/04/18.
//

import UIKit

open class WRGImageGallery: NSObject {
    
    func show(urls:[String], viewController: UIViewController, initialPosition: Int = 0, tabBarToClose: MainTabBarController?){
        
                if let galleryController = UIStoryboard(name: "ImageGallery", bundle: nil).instantiateInitialViewController() as? WRGGalleryController{
                    galleryController.imageUrl = urls
                    galleryController.initialPosition = initialPosition
                    galleryController.tabBarToClose = tabBarToClose
                    galleryController.modalPresentationStyle = .fullScreen
                    viewController.present(galleryController, animated: true, completion: nil)
                }
    }
    
}
