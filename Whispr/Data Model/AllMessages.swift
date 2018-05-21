//
//  AllMessages.swift
//  Whispr
//
//  Created by Neema Badihian on 5/20/18.
//  Copyright © 2018 Neema Badihian. All rights reserved.
//

import Foundation
import RealmSwift

class AllMessages: Object {
    @objc dynamic var messageBody : String = ""
    @objc dynamic var recipientName : String = ""
    @objc dynamic var recipientNumber : String = ""
    @objc dynamic var senderNumber : String = ""
    @objc dynamic var timeStamp : String = ""
    @objc dynamic var messageID : String = ""
    var parentCategory = LinkingObjects(fromType: All.self, property: "allMessages")
}

