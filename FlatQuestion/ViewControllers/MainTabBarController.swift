import Foundation

import UIKit

class MainTabBarController: UITabBarController {

    @IBOutlet var plusButton: UIButton!
    @IBOutlet weak var centerButton: UIButton!

  override func viewDidLoad() {
    super.viewDidLoad()
    
    createListenerForChatList()
  }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupCenterButton()
    }
    
    private func createListenerForChatList() {
        guard let id = UserSettings.appUser?.id else { return }
        ChatsService.shared.createListener(forUserId: id) { () in
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: Notification.Name("ChatListUpdated"), object: nil)
            }
        }
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
        guard UserSettings.appUser?.flats?.count == 0 else {
            let vc = ModalPopUpViewController(delegate: self, title: "Внимание".localized, description: "Вы пытаетесь создать еще один флет. Пожалуйста, удалите уже существующий".localized, createButtonText: "Принять".localized)
            vc.transitioningDelegate = self
            present(vc, animated: true, completion: nil)
            return
        }
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
        guard topVC.children.count > 0 else { return }
        let lstVC = topVC.children[topVC.children.count - 1]
        switch lstVC {
        case is MapViewController:
            let vc = lstVC as? MapViewController
            vc?.updateFlats()
        case is ProfileViewController:
            let vc = lstVC as? ProfileViewController
            vc?.setupData()
        default: break
        }
    }
    
}

extension MainTabBarController: ModalPopUpViewControllerProtocol {
    func createButtonPressed() {
        print("")
    }
}

extension MainTabBarController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if presented is AcceptModalViewController || presented is ModalPopUpViewController || presented is QuestionModalViewController{
            return TransparentBackgroundModalPresenter(isPush: true, originFrame: UIScreen.main.bounds)
        } else {
        return SuccessModalPresenter(isPush: true, originFrame: UIScreen.main.bounds)
        }
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if dismissed is AcceptModalViewController || dismissed is ModalPopUpViewController || dismissed is QuestionModalViewController{
        return TransparentBackgroundModalPresenter(isPush: false)
        } else {
            return SuccessModalPresenter(isPush: false)
        }
    }
}

extension MainTabBarController {
    func setTabBarVisible(visible:Bool, duration: TimeInterval, animated:Bool) {
        if (tabBarIsVisible() == visible) { return }
        let frame = self.tabBar.frame
        let height = frame.size.height
        let offsetY = (visible ? -height : height)

        UIViewPropertyAnimator(duration: duration, curve: .linear) {
            self.centerButton.alpha = visible ? 1 : 0
            self.tabBar.alpha = visible ? 1 : 0
            let _ = self.tabBar.frame.offsetBy(dx:0, dy:offsetY)
            self.view.frame = CGRect(x:0,y:0,width: self.view.frame.width, height: self.view.frame.height + offsetY)
            self.view.setNeedsDisplay()
            self.view.layoutIfNeeded()
        }.startAnimation()
    }

    func tabBarIsVisible() ->Bool {
        return self.tabBar.frame.origin.y < UIScreen.main.bounds.height
    }
}
