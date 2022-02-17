import Foundation
import CryptoSwift

final class AuthController {
  
  static let serviceName = "FriendvatarsService"
  
  class func signOut() throws {
    // 1: Check if you’ve stored a current user, and bail out early if you haven’t.
    guard let currentUser = Settings.currentUser else {
      return
    }
    
    // 2: Delete the password hash from the Keychain.
    try KeychainPasswordItem(service: serviceName, account: currentUser.email).deleteItem()
    
    // 3: Clear the user object and post the notification.
    Settings.currentUser = nil
    NotificationCenter.default.post(name: .loginStatusChanged, object: nil)
  }


  static var isSignedIn: Bool {
    // 1: Check the current user stored in UserDefaults.
    //    If no user exists, there won’t be an identifier to lookup the password hash from the Keychain,
    //    so you indicate they are not signed in.
    guard let currentUser = Settings.currentUser else {
      return false
    }
    
    do {
      // 2: Read the password hash from the Keychain,
      //    and if a password exists and isn’t blank, the user is considered logged in.
      let password = try KeychainPasswordItem(service: serviceName, account: currentUser.email).readPassword()
      return password.count > 0
    } catch {
      return false
    }
  }

 
  class func signIn(_ user: User, password: String) throws {
    let finalHash = passwordHash(from: user.email, password: password)
    try KeychainPasswordItem(service: serviceName, account: user.email).savePassword(finalHash)
    
    Settings.currentUser = user
    
    NotificationCenter.default.post(name: .loginStatusChanged, object: nil)
  }
  
  class func passwordHash(from email: String, password: String) -> String {
    let salt = "x4vV8bGgqqmQwgCoyXFQj+(o.nUNQhVP7ND"
    return "\(password).\(email).\(salt)".sha256()
  }
}

extension Notification.Name {
  static let loginStatusChanged = Notification.Name("com.razeware.auth.changed")
}

