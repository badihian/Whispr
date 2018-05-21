//
//  Received.swift
//  Whispr
//
//  Created by Neema Badihian on 5/20/18.
//  Copyright © 2018 Neema Badihian. All rights reserved.
//

import Foundation
import RealmSwift

class Received: Object {
    @objc dynamic var phoneNumber : String = ""
    var parentCategory = LinkingObjects(fromType: User.self, property: "received")
    let receivedMessages = List<ReceivedMessages>()
}

