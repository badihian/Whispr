//
//  User.swift
//  Whispr
//
//  Created by Neema Badihian on 5/20/18.
//  Copyright © 2018 Neema Badihian. All rights reserved.
//

import Foundation
import RealmSwift

class User: Object {
    @objc dynamic var phoneNumber : String = ""
    let contacts = List<Contacts>()
    let sent = List<Sent>()
    let received = List<Received>()
    let all = List<All>()
}
