import UIKit

final class AppController {
  
  static let shared = AppController()
  
  var window: UIWindow!
  var rootViewController: UIViewController? {
    didSet {
      if let vc = rootViewController {
        window.rootViewController = vc
      }
    }
  }
  
  init() {
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(handleAuthState),
      name: .loginStatusChanged,
      object: nil
    )
  }

  
  func show(in window: UIWindow?) {
    guard let window = window else {
      fatalError("Cannot layout app with a nil window.")
    }
    
    window.backgroundColor = .black
    self.window = window
    
    rootViewController = SplashViewController()
    window.makeKeyAndVisible()
  }
  
  @objc func handleAuthState() {
    if AuthController.isSignedIn {
      rootViewController = NavigationController(rootViewController: FriendsViewController())
    } else {
      rootViewController = AuthViewController()
    }
  }
}
