//
//  ChatMessagesTableViewCell.swift
//  Blabber
//
//  Created by Neema Badihian on 3/15/18.
//  Copyright © 2018 Neema Badihian. All rights reserved.
//

import UIKit

class ChatMessagesTableViewCell: UITableViewCell {
    
    @IBOutlet weak var messageBackground: UIView!
    @IBOutlet weak var messageBody: UILabel!
    @IBOutlet weak var senderBackground: UIView!
    @IBOutlet weak var senderName: UILabel!
    @IBOutlet weak var chatCellLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var chatCellTrailingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var cellMessageBodyTrailingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var cellMessageBodyLeadingConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
