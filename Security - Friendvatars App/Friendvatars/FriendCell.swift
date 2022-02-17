import UIKit

class FriendCell: UITableViewCell {

  @IBOutlet var nameLabel: UILabel!
  @IBOutlet var avatarImageView: UIImageView!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    avatarImageView.clipsToBounds = true
    avatarImageView.layer.cornerRadius = avatarImageView.bounds.width / 2
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    
    avatarImageView.image = nil
  }
  
}
