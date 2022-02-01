//
//  UserTableViewCell.swift
//  Messenger
//
//  Created by Nir Zioni on 25/01/2022.
//

import UIKit

class UserTableViewCell: UITableViewCell {

    //MARK: - IBOutlets
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

    public func configure(user: User){
        usernameLabel.text = user.username
        statusLabel.text = user.status
        setAvatar(avatarLink: user.avatarLink)
    }
    
    private func setAvatar(avatarLink: String){
        if avatarLink != "" {
            FileStorage.downloadImage(imageURL: avatarLink) { (avatarImage) in
                self.avatarImageView.image = avatarImage?.circleMasked
            }
            
        } else {
            self.avatarImageView.image = UIImage(named: "avatar")?.circleMasked
        }
    }
}
