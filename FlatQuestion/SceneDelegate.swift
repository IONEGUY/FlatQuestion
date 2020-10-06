import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    private var currentScene: UIScene?
    private var currentOptions: UIScene.ConnectionOptions?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(frame: UIScreen.main.bounds)
        currentScene = scene
        currentOptions = connectionOptions
        
        let launchVC = AnimatedLaunchViewController(nibName: "AnimatedLaunchViewController", bundle: nil)
        launchVC.delegate = self
        window?.rootViewController = launchVC
        window?.makeKeyAndVisible()
        window?.windowScene = windowScene
    }
    
    func chooseNextVCAndMove() {
        guard let windowScene = (currentScene as? UIWindowScene) else { return }
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let mainViewController = storyBoard.instantiateViewController(withIdentifier: "main")
        mainViewController.modalPresentationStyle = .fullScreen
        let viewController = UserSettings.appUser == nil || UserSettings.appUser?.sex == nil ? LoginViewController() : mainViewController
        if let vc = mainViewController as? UITabBarController {
            vc.selectedIndex = 3
        }
        window?.rootViewController = mainViewController
        window?.makeKeyAndVisible()
        window?.windowScene = windowScene
        
        //if UserSettings.appUser?.sex != nil{
        
        if let urlinfo = currentOptions?.urlContexts {
            if let url = urlinfo.first?.url {
                self.scene(windowScene, openURLContexts: urlinfo)
            }
        }
        UIView.transition(with: self.window!, duration: 0.8, options: .transitionFlipFromRight, animations: nil, completion: nil)
        
        currentOptions = nil
        currentScene = nil
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        if let url = URLContexts.first?.url {
            print("url")
            let urlString = url.absoluteString
            guard let flatString = urlString.components(separatedBy: "//").last, let flatId = Int(flatString) else { return }
            if UserSettings.appUser != nil {
                guard let rootVC = window?.rootViewController as? MainTabBarController else { return }
                rootVC.selectedIndex = 1
                if let vc = rootVC.topMostViewController() as? MapViewController {
                    vc.openFlatWith(id: flatId)
                }
            }
        }
    }
    
}

extension SceneDelegate: AnimatedLaunchProtocol {
    func willClose() {
        chooseNextVCAndMove()
    }
}
