import UIKit
import CryptoSwift

final class FriendsViewController: UITableViewController {
  
  var friends: [User] = []
  var imageCache = NSCache<NSString, UIImage>()
  
  init() {
    super.init(style: .grouped)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    title = "Friendvatars"
    
    let reuseIdentifier = String(describing: FriendCell.self)
    tableView.register(
      UINib(nibName: reuseIdentifier, bundle: nil),
      forCellReuseIdentifier: reuseIdentifier
    )
    
    navigationItem.leftBarButtonItem = UIBarButtonItem(
      title: "Sign Out",
      style: .plain,
      target: self,
      action: #selector(signOut)
    )
    
    friends = [
      User(name: "Bob Appleseed", email: "ryha26+bob@gmail.com"),
      User(name: "Linda Lane", email: "ryha26+linda@gmail.com"),
      User(name: "Todd Watch", email: "ryha26+todd@gmail.com"),
      User(name: "Mark Towers", email: "ryha26+mark@gmail.com")
    ]
  }
  
  // MARK: - Actions
  
  @objc private func signOut() {
    try? AuthController.signOut()
  }
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return friends.isEmpty ? 1 : 2
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return section == 0 ? 1 : friends.count
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 64
  }
  
  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return section == 0 ? "Me" : "Friends"
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: FriendCell.self)) as? FriendCell else {
      fatalError()
    }
    
    let user = indexPath.section == 0 ? Settings.currentUser! : friends[indexPath.row]
    cell.nameLabel.text = user.name
    
    if let image = imageCache.object(forKey: user.email as NSString) {
      cell.avatarImageView.image = image
    } else {
      // 1: Normalize the email according to Gravatar’s docs, then you create a MD5 hash.
      let emailHash = user.email.trimmingCharacters(in: .whitespacesAndNewlines)
                                .lowercased()
                                .md5()

      // 2: Construct the Gravatar URL and URLSession. You load a UIImage from the returned data.
      if let url = URL(string: "https://www.gravatar.com/avatar/" + emailHash) {
        URLSession.shared.dataTask(with: url) { data, response, error in
          guard let data = data, let image = UIImage(data: data) else {
            return
          }
          
          // 3: Cache the image to avoid repeat fetches for an email address.
          self.imageCache.setObject(image, forKey: user.email as NSString)
          
          DispatchQueue.main.async {
            // 4: Reload the row in the table view so the avatar image shows up.
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
          }
        }.resume()
      }

    }
    
    return cell
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
  }
  
}
