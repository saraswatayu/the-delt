//
//  AlertDetailTableViewCell.swift
//  XCHAT
//
//  Created by Mateo Garcia on 12/25/16.
//  Copyright © 2016 Mateo Garcia. All rights reserved.
//

import UIKit
import Parse
import ParseUI

@objc protocol AlertDetailTableViewCellDelegate {
    @objc optional func alertDetailTableViewCell(updateFaved faved: Bool)
    @objc optional func alertDetailTableViewCellDidTapReply()
    @objc optional func alertDetailTableViewCell(updateFlagged flagged: Bool)
}

class AlertDetailTableViewCell: UITableViewCell {
    
    @IBOutlet weak var profileImageView: ProfileImageView!
    @IBOutlet weak var nameLabel: UsernameLabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var usernameLabel: UsernameLabel!
    @IBOutlet weak var subjectLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var photoImageView: UIImageView!
    
    @IBOutlet weak var faveButton: UIButton!
    @IBOutlet weak var faveCountLabel: UILabel!
    @IBOutlet weak var replyButton: UIButton!
    @IBOutlet weak var replyCountLabel: UILabel!
    @IBOutlet weak var flagButton: UIButton!
    
    weak var delegate: AlertDetailTableViewCellDelegate?
    
    var alert: PFObject?
    var faved = false
    var flagged = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.profileImageView.layer.cornerRadius = 3
        self.profileImageView.clipsToBounds = true
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}


// MARK: - Setup

extension AlertDetailTableViewCell {
    func setUpCell(alert: PFObject) {
        self.alert = alert
        if let author = alert["author"] as? PFUser {
            self.profileImageView.user = author
            if let profilePhoto = author["photo"] as? PFFile {
                let pfImageView = PFImageView()
                pfImageView.file = profilePhoto
                pfImageView.load { (image: UIImage?, error: Error?) -> Void in
                    if let error = error {
                        // Log details of the failure
                        print("Error: \(error) \(error.localizedDescription)")
                        
                    } else {
                        self.profileImageView.image = image
                    }
                }
            }
            
            self.nameLabel.user = author
            self.nameLabel.text = author["name"] as? String
            self.usernameLabel.user = author
            self.usernameLabel.text = author.username
        }
        
        if let postedAt = alert["createdAt"] as? Date {
            let dateFormatter = DateFormatter()
            let calendar = Calendar.current
            //        dateFormatter.dateFormat = "M/d"
            //        self.dateLabel.text = dateFormatter.string(from: postedAt)
            
            dateFormatter.amSymbol = "a"
            dateFormatter.pmSymbol = "p"
            var comp = (calendar as NSCalendar).components([.hour, .minute], from: postedAt)
            dateFormatter.dateFormat = "M/d h:mma"
            if comp.minute == 0 {
                dateFormatter.dateFormat = "ha"
            }
            self.dateLabel.text = dateFormatter.string(from: postedAt)
        }
        
        self.subjectLabel.text = alert["subject"] as? String
        self.messageLabel.text = alert["message"] as? String
        
        if let photo = alert["photo"] as? PFFile {
            print("ALERT PHOTO URL:", photo.url)
            
            let pfImageView = PFImageView()
            pfImageView.file = photo
            pfImageView.load { (image: UIImage?, error: Error?) -> Void in
                if let error = error {
                    // Log details of the failure
                    print("Error: \(error) \(error.localizedDescription)")
                } else {
                    self.photoImageView.image = image
                }
            }
        }
        
        // Faves.
        if let favedBy = alert["favedBy"] as? [String] {
            if let username = PFUser.current()?.username {
                self.faved = favedBy.contains(username)
                self.faveButton.isSelected = self.faved
            }
        }
        self.faveButton.isSelected = self.faved
        if let faveCount = alert["faveCount"] as? Int {
            if faveCount > 0 {
                self.faveCountLabel.text = String(faveCount)
            } else {
                self.faveCountLabel.text = ""
            }
        } else {
            self.faveCountLabel.text = ""
        }
        
        // Replies.
        if let replyCount = alert["replyCount"] as? Int {
            if replyCount > 0 {
                self.replyCountLabel.text = String(replyCount)
            } else {
                self.replyCountLabel.text = ""
            }
        } else {
            self.replyCountLabel.text = ""
        }
        
        // Flagged.
        if let flagged = alert["flagged"] as? Bool {
            self.flagged = flagged
            self.flagButton.isSelected = self.flagged
        }
        self.flagButton.isSelected = self.flagged
    }
}


// MARK: - Actions

extension AlertDetailTableViewCell {
    @IBAction func onFaveButtonTapped(_ sender: Any) {
        self.faveButton.isSelected = !self.faved
        self.delegate?.alertDetailTableViewCell?(updateFaved: !self.faved)
    }
    
    @IBAction func onReplyButtonTapped(_ sender: Any) {
        self.delegate?.alertDetailTableViewCellDidTapReply?()
    }
    
    @IBAction func onFlagButtonTapped(_ sender: Any) {
        self.flagButton.isSelected = !self.flagged
        self.delegate?.alertDetailTableViewCell?(updateFlagged: !self.flagged)
    }
}
