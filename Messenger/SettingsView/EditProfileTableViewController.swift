//
//  EditProfileTableViewController.swift
//  Messenger
//
//  Created by Nir Zioni on 06/01/2022.
//

import UIKit
import Gallery
import ProgressHUD

class EditProfileTableViewController: UITableViewController {

    
    //MARK: - IBOutlets
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var usernameTextField: UITextField!
    
    //MARK: - Vars
    var gallery: GalleryController!
    
    //MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        //remove unnecessary table cells
        tableView.tableFooterView = UIView()

        configureTextField()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showUserInfo()
    }

    //MARK: - TableViewDelegate
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor(named:"tableViewBackgroungColor")
        
        return headerView
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 0.0 : 30.0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      
        tableView.deselectRow(at: indexPath, animated: true)
        
        //show status view
        if indexPath.section == 1 && indexPath.row == 0 {
            performSegue(withIdentifier: "EditProfileToStatusSeg", sender: self)
        }
    }
    
    //MARK: - IBActions
    @IBAction func editButtonPressed(_ sender: Any) {
        showImageGallery()
    }
    
   
    //MARK: - UpdateUI
    private func showUserInfo(){
        if let user = User.currentUser{
            usernameTextField.text = user.username
            statusLabel.text = user.status
            
            if user.avatarLink != "" {
                FileStorage.downloadImage(imageURL: user.avatarLink) { avatarImage in
                    self.avatarImageView.image = avatarImage?.circleMasked
                }
            }
        }
    }
    
    //MARK: - Configure
    private func configureTextField(){
        usernameTextField.delegate = self   //I conformed for this protocol in the extension below
        usernameTextField.clearButtonMode = .whileEditing
    }
    
    //MARK: - Gallery
    private func showImageGallery(){
        self.gallery = GalleryController()
        self.gallery.delegate = self //I conformed for this protocol in the extension below
        
        Config.tabsToShow = [.imageTab, .cameraTab]
        Config.Camera.imageLimit = 1
        Config.initialTab = .imageTab
        
        self.present(gallery, animated: true, completion: nil)
    }
    
    //MARK: - UploadImages
    private func uploadAvatarImage(_ image: UIImage){
        let fileDirectory = "Avatars/" + "_\(User.currentId)" + ".jpg"
        FileStorage.uploadImage(image, directory: fileDirectory) { avatarLink in
            if var user = User.currentUser {
                user.avatarLink = avatarLink ?? ""
                saveUserLocally(user)
                FirebaseUserListener.shared.saveUsersForFirestore(user)
            }
            
            //save image locally
            FileStorage.saveFileLocally(fileDate: image.jpegData(compressionQuality: 1.0)! as NSData, fileName: User.currentId)
        }
    }

}

extension EditProfileTableViewController : UITextFieldDelegate {
    
    //Used to update username lacally and in Firebase
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == usernameTextField {
            if textField.text != "" {
                if var user = User.currentUser {
                    user.username = textField.text!
                    saveUserLocally(user)
                    FirebaseUserListener.shared.saveUsersForFirestore(user)
                    
                }
            }
            textField.resignFirstResponder()
            return false
        }
        
        return true
    }
}

extension EditProfileTableViewController : GalleryControllerDelegate{
    
    func galleryController(_ controller: GalleryController, didSelectImages images: [Image]) {
        if images.count > 0 {
            images.first!.resolve { (avatarImage) in
                
                if avatarImage != nil {
                    self.uploadAvatarImage(avatarImage!)
                    self.avatarImageView.image = avatarImage?.circleMasked
                    
                } else {
                    ProgressHUD.showError("Couldn't select image")
                }
                
            }
        }
        controller.dismiss(animated: true, completion: nil)
    }
    
    func galleryController(_ controller: GalleryController, didSelectVideo video: Video) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func galleryController(_ controller: GalleryController, requestLightbox images: [Image]) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func galleryControllerDidCancel(_ controller: GalleryController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    
}
