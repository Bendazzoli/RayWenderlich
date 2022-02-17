import UIKit

final class AuthViewController: UIViewController {
  
  override var prefersStatusBarHidden: Bool {
    return true
  }
  
  private enum TextFieldTag: Int {
    case email
    case password
  }
  
  @IBOutlet weak var containerView: UIView!
  @IBOutlet weak var emailField: UITextField!
  @IBOutlet weak var passwordField: UITextField!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var signInButton: UIButton!
  @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    containerView.transform = CGAffineTransform(scaleX: 0, y: 0)
    containerView.backgroundColor = .rwGreen
    containerView.layer.cornerRadius = 7
    
    emailField.delegate = self
    emailField.tintColor = .rwGreen
    emailField.tag = TextFieldTag.email.rawValue
    
    passwordField.delegate = self
    passwordField.tintColor = .rwGreen
    passwordField.tag = TextFieldTag.password.rawValue
    
    titleLabel.isHidden = true
    
    view.addGestureRecognizer(
      UITapGestureRecognizer(
        target: self,
        action: #selector(handleTap(_:))
      )
    )
    
    registerForKeyboardNotifications()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    let animation = CABasicAnimation(keyPath: "transform.scale")
    
    animation.duration = 0.3
    animation.fromValue = 0
    animation.toValue = 1
    
    CATransaction.begin()
    CATransaction.setCompletionBlock {
      self.emailField.becomeFirstResponder()
      self.titleLabel.isHidden = false
    }
    containerView.layer.add(animation, forKey: "scale")
    containerView.transform = CGAffineTransform(scaleX: 1, y: 1)
    CATransaction.commit()
  }
  
  // MARK: - Actions
  
  @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
    view.endEditing(true)
  }
  
  @IBAction func signInButtonPressed() {
    signIn()
  }
  
  // MARK: - Helpers
  
  private func registerForKeyboardNotifications() {
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(keyboardWillShow(_:)),
      name: NSNotification.Name.UIKeyboardWillShow,
      object: nil
    )
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(keyboardWillHide(_:)),
      name: NSNotification.Name.UIKeyboardWillHide,
      object: nil
    )
  }
  
  private func signIn() {
    // 1: dismiss the keyboard to confirm that the user’s action did something.
    view.endEditing(true)
    
    // 2: You take the email and password the user input. If either is zero length, then you don’t want to continue.
    //    In a real world application, you should show the user an error here as well.
    guard let email = emailField.text, email.count > 0 else {
      return
    }
    guard let password = passwordField.text, password.count > 0 else {
      return
    }
    
    // 3: Assign a name to the user which, for purposes of this tutorial, you take from the device name.
    let name = UIDevice.current.name
    let user = User(name: name, email: email)
    
    do {
      try AuthController.signIn(user, password: password)
    } catch {
      print("Error signing in: \(error.localizedDescription)")
    }
  }

  
  // MARK: - Notifications
  
  @objc internal func keyboardWillShow(_ notification: Notification) {
    guard let userInfo = notification.userInfo else {
      return
    }
    guard let keyboardHeight = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height else {
      return
    }
    guard let keyboardAnimationDuration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue else {
      return
    }
    guard let keyboardAnimationCurve = (userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber)?.uintValue else {
      return
    }
    
    let options = UIViewAnimationOptions(rawValue: keyboardAnimationCurve << 16)
    bottomConstraint.constant = keyboardHeight + 32
    
    UIView.animate(withDuration: keyboardAnimationDuration, delay: 0, options: options, animations: {
      self.view.layoutIfNeeded()
    }, completion: nil)
  }
  
  @objc internal func keyboardWillHide(_ notification: Notification) {
    guard let userInfo = notification.userInfo else {
      return
    }
    guard let keyboardAnimationDuration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue else {
      return
    }
    guard let keyboardAnimationCurve = (userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber)?.uintValue else {
      return
    }
    
    let options = UIViewAnimationOptions(rawValue: keyboardAnimationCurve << 16)
    bottomConstraint.constant = 0
    
    UIView.animate(withDuration: keyboardAnimationDuration, delay: 0, options: options, animations: {
      self.view.layoutIfNeeded()
    }, completion: nil)
  }

}

extension AuthViewController: UITextFieldDelegate {
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    guard let text = textField.text, text.count > 0 else {
      return false
    }
    
    switch textField.tag {
    case TextFieldTag.email.rawValue:
      passwordField.becomeFirstResponder()
    case TextFieldTag.password.rawValue:
      signIn()
    default:
      return false
    }
    
    return true
  }
  
}

