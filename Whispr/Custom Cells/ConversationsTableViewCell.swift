//
//  ConversationsTableViewCell.swift
//  Whispr
//
//  Created by Neema Badihian on 3/18/18.
//  Copyright © 2018 Neema Badihian. All rights reserved.
//

import UIKit

class ConversationsTableViewCell: UITableViewCell {
    @IBOutlet weak var contactLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func selectConversationButton(_ sender: Any) {
    }
    
}
