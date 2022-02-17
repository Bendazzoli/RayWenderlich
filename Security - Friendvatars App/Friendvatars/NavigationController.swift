import UIKit

final class NavigationController: UINavigationController {

  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    navigationBar.tintColor = .white
    navigationBar.barTintColor = .rwGreen
    navigationBar.prefersLargeTitles = true
    navigationBar.titleTextAttributes = [
      NSAttributedStringKey.foregroundColor: UIColor.white
    ]
    navigationBar.largeTitleTextAttributes = navigationBar.titleTextAttributes
  }
  
}
